//
//  DependenceManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 6/11/25.
//

import Foundation

@Observable
final class DependenceManager: DependenceManagerProtocol {
    var casManager: CASManagerProtocol
    var playerManager: PlayerProtocol
    var recorderManager: RecordingProtocol
    var dateManager: DateManagerProtocol
    var permissionManager: PermissionProtocol
    
    init() {
        casManager = CASManager()
        playerManager = PlayerManager()
        recorderManager = RecordManager()
        dateManager = DateManager()
        permissionManager = PermissionManager()
    }
}


protocol DependenceManagerProtocol {
    var casManager: CASManagerProtocol { get }
    var playerManager: PlayerProtocol { get }
    var recorderManager: RecordingProtocol { get }
    var dateManager: DateManagerProtocol { get }
    var permissionManager: PermissionProtocol { get }
}
