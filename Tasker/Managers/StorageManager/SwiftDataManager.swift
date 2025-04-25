//
//  SwiftDataManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataManager: SwiftDataProtocol {
    typealias Model = TaskModel
    
    internal var modelContext: ModelContext
    internal var modelContainer: ModelContainer
    
    init() {
        modelContainer = try! ModelContainer(for: Model.self)
        modelContext = modelContainer.mainContext
    }
    
    func saveTask(_ task: Model) {
        modelContext.insert(task)
    }
    
    func fetchAllActiveTask() -> [Model] {
        let tasksPredicate = #Predicate<Model> { $0.deleted == nil }
        let descriptor = FetchDescriptor<Model>(predicate: tasksPredicate, sortBy: [SortDescriptor(\.notificationDate)])
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Couldn't fetch active tasks")
            return []
        }
    }
    
    func fectchAllDeletedTask() -> [Model] {
        let predicate = #Predicate<Model> { $0.deleted != nil }
        let descriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: [SortDescriptor(\.notificationDate)])
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Couldn't fetch deleted tasks")
            return []
        }
    }
}
