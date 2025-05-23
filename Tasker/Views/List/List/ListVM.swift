//
//  ListVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import Foundation
import SwiftUI

@Observable
final class ListVM {
    let dateManager: DateManagerProtocol
    let casManager: CASManagerProtocol
    
    var tasks: [MainModel] {
        casManager.models.filter { model in
            model.value.markAsDeleted == false &&
            model.value.deleted?.contains { $0.deletedFor == selectedDate } != true &&
            isTaskScheduledForDate(model.value, date: selectedDate) &&
            (model.value.done == nil || !model.value.done!.contains { $0.completedFor == selectedDate })
        }
    }
    
    var completedTasks: [MainModel] {
        casManager.models.filter { model in
            model.value.markAsDeleted == false &&
            isTaskScheduledForDate(model.value, date: selectedDate) &&
            model.value.done?.contains { $0.completedFor == selectedDate } == true
        }
    }
    
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: dateManager.selectedDate).timeIntervalSince1970
    }
    
    init(casManager: CASManagerProtocol) {
        dateManager = DateManager.shared
        self.casManager = casManager
    }
    
    //MARK: - Check for visible
    private func isTaskScheduledForDate(_ task: TaskModel, date: Double) -> Bool {
        let taskNotificationDate = task.notificationDate
        let taskCreateDate = task.createDate
        
        let dateAsDate = Date(timeIntervalSince1970: date)
        let taskNotificationDateAsDate = Date(timeIntervalSince1970: taskNotificationDate)
        
        guard dateAsDate >= calendar.startOfDay(for: taskNotificationDateAsDate) else {
            return false
        }
        
        if let endDate = task.endDate {
            let taskEndDate = Date(timeIntervalSince1970: endDate)
            guard dateAsDate <= taskEndDate else {
                return false
            }
        }
        
        switch task.repeatTask {
        case .never:
            return taskNotificationDate >= date &&
            taskNotificationDate < date + 86400
            
        case .daily:
            return true
            
        case .weekly:
            let taskWeekday = calendar.component(.weekday, from: taskNotificationDateAsDate)
            let selectedWeekday = calendar.component(.weekday, from: dateAsDate)
            return taskWeekday == selectedWeekday
            
        case .monthly:
            let taskDay = calendar.component(.day, from: taskNotificationDateAsDate)
            let selectedDay = calendar.component(.day, from: dateAsDate)
            return taskDay == selectedDay
            
        case .yearly:
            let taskMonth = calendar.component(.month, from: taskNotificationDateAsDate)
            let taskDay = calendar.component(.day, from: taskNotificationDateAsDate)
            let selectedMonth = calendar.component(.month, from: dateAsDate)
            let selectedDay = calendar.component(.day, from: dateAsDate)
            return taskMonth == selectedMonth && taskDay == selectedDay
            
        case .dayOfWeek:
            let selectedWeekday = calendar.component(.weekday, from: dateAsDate)
            let dayIndex = selectedWeekday - 1
            
            guard dayIndex >= 0 && dayIndex < task.dayOfWeek.count else {
                return false
            }
            
            return task.dayOfWeek[dayIndex].value
        }
    }
}
