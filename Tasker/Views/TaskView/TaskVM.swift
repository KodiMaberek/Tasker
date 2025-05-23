//
//  TaskVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation
import SwiftUICore

@MainActor
@Observable
final class TaskVM {
    var dateManager: DateManagerProtocol
    var playerManager: PlayerProtocol
    var swiftData: SwiftDataProtocol
    
    var task: TaskModel
    
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
    
    @ObservationIgnored
    var color = Color.black {
        didSet {
            task.taskColor = .custom(color.toHex())
        }
    }
    
    var showDatePicker = false
    var showTimePicker = false
    var shareViewIsShowing = false
    
    
    init(task: TaskModel) {
        dateManager = DateManager()
        playerManager = PlayerManager()
        swiftData = SwiftDataManager.shared
        self.task = task
        print(notificationDate)
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
    
    func selectedColorButtonTapped(_ taskColor: TaskColor) {
        task.taskColor = taskColor
    }
    
    func shareViewButtonTapped() {
        shareViewIsShowing.toggle()
    }
    
    func doneButtonTapped() {
        let task = preparedTask()
        swiftData.saveTask(task)
    }
    
    private func preparedTask() -> TaskModel {
        let filledTask = TaskModel(title: task.title.isEmpty ? "New Task" : task.title, info: task.info, createDate: Date.now.timeIntervalSince1970)
        filledTask.notificationDate = notificationDate.timeIntervalSince1970
        filledTask.done = task.done
        filledTask.taskColor = task.taskColor
        filledTask.repeatTask = task.repeatTask
        filledTask.uniqueID = task.uniqueID
        filledTask.audio = task.audio
        filledTask.voiceMode = task.voiceMode
        filledTask.deleted = task.deleted
        filledTask.endDate = task.endDate
        filledTask.previousUniqueID = task.previousUniqueID
        filledTask.secondNotificationDate = task.secondNotificationDate
        
        return filledTask
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
