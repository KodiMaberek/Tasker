//
//  ListVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import Foundation
import SwiftData

@Observable
final class ListVM {
    
    let dateManager: DateManagerProtocol
    let casManager: CASManagerProtocol
    
    var selectedTask: MainModel?
    
    var update = false
    
    var tasks: [MainModel] {
        casManager.models.filter { model in
            model.value.notificationDate >= selectedDate &&
            model.value.notificationDate < selectedDate.advanced(by: 86400) &&
            (model.value.done == nil || !model.value.done!.contains { $0.completedFor == selectedDate })
        }
    }
    
    var completedTasks: [MainModel] {
        casManager.models.filter {
            $0.value.notificationDate >= selectedDate &&
            $0.value.notificationDate < selectedDate.advanced(by: 86400) &&
            $0.value.done?.contains { $0.completedFor == selectedDate } == true
        }
    }
    
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: dateManager.selectedDate).timeIntervalSince1970
    }
    
    init() {
        dateManager = DateManager.shared
        casManager = CASManager.shared
        print("init list VM")
    }
    
    func selectedTaskButtonTapped(_ task: MainModel) {
        selectedTask = task
    }
}
