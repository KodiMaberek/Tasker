//
//  DependenceManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 6/11/25.
//

import Foundation
import SwiftUICore

final class DependenceManager: DependenceManagerProtocol {
    lazy var casManager: CASManagerProtocol = CASManager()
    lazy var playerManager: PlayerManagerProtocol = PlayerManager()
    lazy var recorderManager: RecorderManagerProtocol = RecorderManager()
    lazy var dateManager: DateManagerProtocol = DateManager()
    lazy var permissionManager: PermissionProtocol = PermissionManager()
}

protocol DependenceManagerProtocol {
    var casManager: CASManagerProtocol { get set }
    var playerManager: PlayerManagerProtocol { get }
    var recorderManager: RecorderManagerProtocol { get }
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
