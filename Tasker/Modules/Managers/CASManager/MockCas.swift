//
//  MockCas.swift
//  Managers
//
//  Created by Rodion Akhmedov on 6/13/25.
//

import Foundation
import Models

@Observable
final class MockCas: CASManagerProtocol {
    var models: [MainModel] = [mockModel(), mockModel()]
    
    var taskUpdateTrigger: Bool = false
    
    func saveModel(_ task: MainModel) {
        
    }
    
    func saveAudio(url: URL) -> String? {
        return nil
    }
    
    func fetchModels() -> [MainModel] {
        []
    }
    
    func getData(_ hash: String) -> Data? {
        nil
    }
    
    func deleteModel(_ model: MainModel) {
        
    }
}
