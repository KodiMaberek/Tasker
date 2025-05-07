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
    var dateManager: DateManagerProtocol
    var cas: CASManagerProtocol
    
    var selectedTask: TaskModel?
    var update = false
    
    var latestTasks: [TaskModel] {
        cas.models.filter { $0.notificationDate >= selectedDate && $0.notificationDate < selectedDate.advanced(by: 86400) }
    }
    
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: dateManager.selectedDate).timeIntervalSince1970
    }
    
    init() {
        dateManager = DateManager.shared
        cas = CASManager()
    }
    
    func selectedTaskButtonTapped(_ task: TaskModel) {
        selectedTask = task
    }
}
