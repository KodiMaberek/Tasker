//
//  СASManagerProtocol.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/6/25.
//

import Foundation

protocol CASManagerProtocol {
    var models: [MainModel] { get }
    
    func saveModel(_ task: MainModel)
    func fetchModels() -> [MainModel]
}
