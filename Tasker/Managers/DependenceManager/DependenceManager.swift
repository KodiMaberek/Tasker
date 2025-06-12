//
//  DependenceManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 6/11/25.
//

import Foundation
import SwiftUICore

@Observable
final class DependenceManager: DependenceManagerProtocol {
    var casManager: CASManagerProtocol
    var playerManager: PlayerProtocol
    var recorderManager: RecordingProtocol
    var dateManager: DateManagerProtocol
    var permissionManager: PermissionProtocol
    
    init() {
        print("start")
        casManager = CASManager()
        playerManager = PlayerManager()
        recorderManager = RecordManager()
        dateManager = DateManager()
        permissionManager = PermissionManager()
        print("end")
    }
}


protocol DependenceManagerProtocol {
    var casManager: CASManagerProtocol { get }
    var playerManager: PlayerProtocol { get }
    var recorderManager: RecordingProtocol { get }
    var dateManager: DateManagerProtocol { get }
    var permissionManager: PermissionProtocol { get }
}


struct DependencyKey: EnvironmentKey {
    static var defaultValue: DependenceManagerProtocol = DependenceManager()
}

extension EnvironmentValues {
    var dependencies: DependenceManagerProtocol {
        get { self[DependencyKey.self] }
        set { self[DependencyKey.self] = newValue }
    }
}
