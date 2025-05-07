//
//  CasManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/6/25.
//

import Foundation

@Observable
final class CASManager: CASManagerProtocol {
    @ObservationIgnored
    var cas: MultiCas
    @ObservationIgnored
    var remoteDirectory = "iCloud.com.KodiMaberek.Tasker"
    @ObservationIgnored
    var localDirectory: URL
    
    @ObservationTracked
    var models: [TaskModel] {
        fetchModels()
    }
    
    init() {
        localDirectory = CASManager.createMainDirectory()!
        
        let localCas = FileCas(localDirectory)
        let iCas = FileCas(FileManager.default.url(forUbiquityContainerIdentifier: remoteDirectory) ?? localDirectory)
        
        cas = MultiCas(local: localCas, remote: iCas)
    }
    
    //MARK: Actions for work with CAS
    func saveModel(_ task: TaskModel) {
        let model = Model.initial(task)
        
        do {
            try cas.saveJsonModel(model)
        } catch {
            print("Couldn't save daat inside CAS")
        }
    }
    
    func fetchModels() -> [TaskModel] {
        var models = [TaskModel]()
        
        do {
            let list = try cas.listMutable()
            for mutable in list {
                if let model: MainModel = try cas.loadJsonModel(mutable) {
                    models.append(model.value)
                    print(list.count)
                }
            }
        } catch {
            print("Couldn't fetch models")
        }
        
        return models
    }
    
    
    //MARK: Create directory for CAS
    private static func createMainDirectory() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
            print("Couldn't get acces to file system")
            return nil
        }
        
        let directoryPath = documentDirectory.appending(path: "Storage", directoryHint: .isDirectory)
        
        do {
            try FileManager.default.createDirectory(atPath: directoryPath.path(), withIntermediateDirectories: true)
            return directoryPath
        } catch {
            print("Couldn't create directory")
            return nil
        }
    }
}



