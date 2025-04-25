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
    associatedtype Model
    
    func saveTask(_ task: Model)
    var modelContext: ModelContext { get }
    var modelContainer: ModelContainer { get }
    
    init()
}
