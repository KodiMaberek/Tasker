//
//  СASManagerProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/6/25.
//

import Foundation

protocol CASManagerProtocol {
    
    var models: [TaskModel] { get}
    
    func saveModel(_ task: TaskModel)
    
    func fetchModels() -> [TaskModel]
}
