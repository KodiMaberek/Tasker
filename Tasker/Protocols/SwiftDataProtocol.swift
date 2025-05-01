//
//  SwiftDataProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation
import SwiftData

@MainActor
protocol SwiftDataProtocol {
    var modelContext: ModelContext { get set }
    var modelContainer: ModelContainer { get set }
    
    var update: Bool { get set }
    
    func saveTask(_ task: TaskModel)
    func fetchAllActiveTask() -> [TaskModel]
    func fetchTodayActiveTasks(date: Double) -> [TaskModel]
}
