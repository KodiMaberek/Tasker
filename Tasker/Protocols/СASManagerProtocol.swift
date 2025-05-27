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
    func saveAudio(url: URL) -> String?
    func fetchModels() -> [MainModel]
    func getData(_ hash: String) -> Data?
    func deleteModel(_ model: MainModel)
}
