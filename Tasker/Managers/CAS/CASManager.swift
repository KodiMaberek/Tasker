//
//  CasManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/6/25.
//

import Foundation

@Observable
final class CASManager: CASManagerProtocol {
    
    let cas: MultiCas
    let remoteDirectory = "iCloud.com.KodiMaberek.Tasker"
    
    var localDirectory: URL
    
    var models: [MainModel] = []
    
    init() {
        let localDirectory = CASManager.createMainDirectory()!
        self.localDirectory = localDirectory
        
        let localCas = FileCas(localDirectory)
        let iCas = FileCas(FileManager.default.url(forUbiquityContainerIdentifier: remoteDirectory) ?? localDirectory)
        
        cas = MultiCas(local: localCas, remote: iCas)
        models = fetchModels()
    }
    
    //MARK: Actions for work with CAS
    func saveModel(_ task: MainModel) {
        
        do {
            try cas.saveJsonModel(task)
            models = fetchModels()
        } catch {
            print("Couldn't save daat inside CAS")
        }
    }
    
    func fetchModels() -> [MainModel] {
        let list = try! cas.listMutable()
        
        return list.compactMap { mutable in
            do {
                return try cas.loadJsonModel(mutable)
            } catch {
                print("Error while loading model: \(error)")
                return nil
            }
        }
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



