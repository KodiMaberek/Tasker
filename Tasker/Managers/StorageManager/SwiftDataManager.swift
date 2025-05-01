//
//  SwiftDataManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SwiftDataManager: SwiftDataProtocol {
    typealias Model = TaskModel
    
    static let shared = SwiftDataManager()
    
    var modelContext: ModelContext
    var modelContainer: ModelContainer
    
    var update = false
    
    init() {
        let container = try! ModelContainer(for: Model.self, CompleteRecord.self, DeleteRecord.self)
        self.modelContainer = container
        self.modelContext = container.mainContext
    }
    
    func saveTask(_ task: Model) {
        modelContext.insert(task)
        try? modelContext.save()
        update.toggle()
    }
    
    func fetchAllActiveTask() -> [Model] {
        let tasksPredicate = #Predicate<Model> {
            $0.deleted != nil
        }
        let descriptor = FetchDescriptor<Model>(
            predicate: tasksPredicate,
            sortBy: [SortDescriptor(
                \.notificationDate
            )]
        )
        
        do {
            let tasks = try modelContext.fetch(
                descriptor
            )
            return tasks
        } catch {
            print(
                "Couldn't fetch active tasks"
            )
            return []
        }
    }
    
    //TODO: Fix predicate
    func fetchTodayActiveTasks(date: Double) -> [Model] {
        let nextDay = date + 86400
        
        let predicate = #Predicate<Model> { task in
            task.notificationDate >= date && task.notificationDate <= nextDay && task.done!.contains(where: { $0.completedFor != date })
        }
        
        do {
            let descriptor = FetchDescriptor<Model>(
                predicate: predicate
            )
            let tasks = try modelContext.fetch(
                descriptor
            )
            return tasks
        } catch {
            print(
                "Error fetching tasks: \(error)"
            )
            return []
        }
    }
    
    //    func fetchLatestTaskForToday(date: Double) -> [Model] {
    //        let taskPredicate = #Predicate<Model> {$0.notificationDate ?? 00 >= date }
    //
    //        let descriptor = FetchDescriptor<Model>(predicate: taskPredicate,
    //                                                sortBy: [SortDescriptor(\.notificationDate)])
    //
    //        do {
    //            let tasks = try modelContext.fetch(descriptor)
    //            return tasks
    //        } catch {
    //            print("Couldn't fetch latest task for today")
    //            return []
    //        }
    //    }
    
    func fectchAllDeletedTask() -> [Model] {
        let predicate = #Predicate<Model> { $0.deleted != nil }
        let descriptor = FetchDescriptor<Model>(
            predicate: predicate,
            sortBy: [SortDescriptor(
                \.notificationDate
            )]
        )
        
        do {
            return try modelContext
                .fetch(
                    descriptor
                )
        } catch {
            print(
                "Couldn't fetch deleted tasks"
            )
            return []
        }
    }
}
