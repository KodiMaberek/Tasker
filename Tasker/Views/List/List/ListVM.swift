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
    @ObservationIgnored
    @Injected(\.dateManager) private var dateManager: DateManagerProtocol
    @ObservationIgnored
    @Injected(\.casManager) private var casManager: CASManagerProtocol
    @ObservationIgnored
    @Injected(\.playerManager) private var playerManager: PlayerManagerProtocol
    
    //MARK: UI State
    var startSwipping = false
    var contentHeight: CGFloat = 0
    
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
    
    var todayTasks: [MainModel] {
        casManager.models.filter { model in
            model.value.markAsDeleted == false &&
            isTaskScheduledForDate(model.value, date: selectedDate)
        }
    }
    
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: dateManager.selectedDate).timeIntervalSince1970
    }
    
    //MARK: - Check for visible
    private func isTaskScheduledForDate(_ task: TaskModel, date: Double) -> Bool {
        let taskNotificationDate = task.notificationDate
        
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
    
    func backToTodayButtonTapped() {
        dateManager.backToToday()
    }
    
    func nextDaySwiped() {
        dateManager.addOneDay()
    }
    
    func previousDaySwiped() {
        dateManager.subtractOneDay()
    }
    
    //MARK: - Calculate size for gestureView
    func calculateGestureViewHeight(screenHeight: CGFloat, contentHeight: CGFloat, safeAreaTop: CGFloat, safeAreaBottom: CGFloat) -> CGFloat {
        let availableScreenHeight = screenHeight - safeAreaTop - safeAreaBottom
        let remainingHeight = availableScreenHeight - contentHeight
        
        let minGestureHeight: CGFloat = 50
        var maxGestureHeight: CGFloat = 250
        
        switch todayTasks.count {
        case 0: maxGestureHeight = 800
        case 1...2: maxGestureHeight = 500
        case 3: maxGestureHeight = 400
        case 4: maxGestureHeight = 350
        case 5: maxGestureHeight = 300
        default: break
        }
        
        let idealGestureHeight: CGFloat = 150
        
        switch remainingHeight {
        case let height where height >= idealGestureHeight:
            return min(height, maxGestureHeight)
            
        case let height where height >= minGestureHeight:
            return height
            
        default:
            return minGestureHeight
        }
    }
}
