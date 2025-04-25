//
//  TaskVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation

@Observable
final class TaskVM {
    var dateManager: DateProtocol
    var playerManager: PlayerProtocol
    
    var calendar: Calendar {
        dateManager.calendar
    }
    
    private var lastChangeTime = Date()
    private var debounceTimer: Timer?
    private var lastNotificationDate = Date()
    
    var notificationDate: Date = Date() {
        didSet {
            checkTimeAfterSelected()
        }
    }
    
    var showDatePicker = false
    var showTimePicker = false
    
    init() {
        dateManager = DateManager()
        playerManager = PlayerManager()
    }
    
    func onAppear() {
        updateActuallyTime()
    }
    
    func selectDateButtonTapped() {
        showDatePicker.toggle()
    }
    
    func selectTimeButtonTapped() {
        showTimePicker.toggle()
    }
    
    func dateToString() -> String {
        if calendar.isDateInToday(notificationDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(notificationDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(notificationDate) {
            return "Yesterday"
        } else {
            return dateManager.dateToString(date: notificationDate, format: "MMMM d")
        }
    }
    
    private func updateActuallyTime() {
        notificationDate = dateManager.getDefaultNotificationTime()
    }
    
    private func dateHasBeenSelected() {
        showDatePicker = false
        showTimePicker = false
    }
    
    private func checkTimeAfterSelected() {
        debounceTimer?.invalidate()
        
        lastChangeTime = Date()
        
        let calendar = Calendar.current
        let oldComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: lastNotificationDate)
        let newComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: notificationDate)
        
        let timeInterval: TimeInterval
        
        if oldComponents.day != newComponents.day ||
            oldComponents.month != newComponents.month ||
            oldComponents.year != newComponents.year {
            
            timeInterval = 0.1
        } else {
            timeInterval = 0.8
        }
        
        lastNotificationDate = notificationDate
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            if let self = self, Date().timeIntervalSince(self.lastChangeTime) >= timeInterval {
                self.dateHasBeenSelected()
            }
        }
    }
}
