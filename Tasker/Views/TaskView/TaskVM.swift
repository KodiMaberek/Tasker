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
    //MARK: - Dependencies
    let dateManager: DateManagerProtocol
    let playerManager: PlayerProtocol
    let casManager: CASManagerProtocol
    
    //MARK: Model
    var mainModel: MainModel
    var task: TaskModel
    
    //MARK: UI States
    var showDatePicker = false
    var showTimePicker = false
    var shareViewIsShowing = false
    
    //MARK: - Computed properties
    var calendar: Calendar {
        dateManager.calendar
    }
    
    var notificationDate = Date() {
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
    
    //MARK: - Private properties
    private var lastChangeTime = Date()
    private var debounceTimer: Timer?
    private var lastNotificationDate = Date()
    
    
    //MARK: - Init
    init(mainModel: MainModel, casManager: CASManagerProtocol) {
        dateManager = DateManager.shared
        playerManager = PlayerManager()
        self.casManager = casManager
        self.mainModel = mainModel
        self.task = mainModel.value
        
        notificationDate = Date(timeIntervalSince1970: mainModel.value.notificationDate)
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
        let mainModel = self.mainModel
        mainModel.value = preparedTask()
        casManager.saveModel(mainModel)
        print(Date(timeIntervalSince1970: mainModel.value.notificationDate))
    }
    
    private func preparedTask() -> TaskModel {
        var filledTask = TaskModel(id: UUID().uuidString, title: task.title.isEmpty ? "New Task" : task.title, info: task.info, createDate: task.createDate)
        filledTask.notificationDate = notificationDate.timeIntervalSince1970
        filledTask.done = task.done
        filledTask.taskColor = task.taskColor
        filledTask.repeatTask = task.repeatTask
        filledTask.audio = task.audio
        filledTask.voiceMode = task.voiceMode
        filledTask.deleted = task.deleted
        filledTask.endDate = task.endDate
        filledTask.previousUniqueID = task.previousUniqueID
        filledTask.secondNotificationDate = task.secondNotificationDate
        
        return filledTask
    }
    
    func dateToString() -> String {
        if calendar.isDateInToday(dateManager.selectedDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(dateManager.selectedDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(dateManager.selectedDate) {
            return "Yesterday"
        } else {
            return dateManager.dateToString(date: dateManager.selectedDate, format: "MMMM d")
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
            Task { @MainActor in
                if let self = self, Date().timeIntervalSince(self.lastChangeTime) >= timeInterval {
                    self.dateHasBeenSelected()
                }
            }
        }
    }
}
