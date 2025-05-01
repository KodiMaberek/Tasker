//
//  ListVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class ListVM {
    var swiftData: SwiftDataProtocol
    var dateManager: DateManagerProtocol
    
    var selectedTask: TaskModel?
    var update = false
    
    var latestTasks: [TaskModel] {
        swiftData.fetchTodayActiveTasks(date: selectedDate)
    }
    
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: dateManager.selectedDate).timeIntervalSince1970
    }
    
    init() {
        swiftData = SwiftDataManager.shared
        dateManager = DateManager.shared
    }
    
    func selectedTaskButtonTapped(_ task: TaskModel) {
        selectedTask = task
    }
}
