//
//  DependenciesManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 6/11/25.
//

import Foundation

final class DependenciesManager: DependenciesManagerProtocol {
    lazy var casManager: CASManagerProtocol = CASManager()
    lazy var playerManager: PlayerManagerProtocol = PlayerManager()
    lazy var recorderManager: RecorderManagerProtocol = RecorderManager()
    lazy var dateManager: DateManagerProtocol = DateManager()
    lazy var permissionManager: PermissionProtocol = PermissionManager()
    lazy var taskManager: TaskManagerProtocol = TaskManager()
}

protocol DependenciesManagerProtocol {
    var casManager: CASManagerProtocol { get }
    var playerManager: PlayerManagerProtocol { get }
    var recorderManager: RecorderManagerProtocol { get }
    var dateManager: DateManagerProtocol { get }
    var permissionManager: PermissionProtocol { get }
    var taskManager: TaskManagerProtocol { get }
}

protocol DependencyRegister {
    var manager: DependenciesManagerProtocol { get set }
}

enum DependependencyContext {
    private static var _current: DependencyRegister = DefaultRegister()
    
    static var current: DependencyRegister {
        get {
            _current
        }
        set {
            _current = newValue
        }
    }
    
    private struct DefaultRegister: DependencyRegister {
        var manager: DependenciesManagerProtocol = DependenciesManager()
    }
}

@propertyWrapper
final class Injected<T> {
    private var keyPath: KeyPath<DependenciesManagerProtocol, T>
    private var cashed: T?
    
    init(_ keyPath: KeyPath<DependenciesManagerProtocol, T>) {
        self.keyPath = keyPath
    }
    
    var wrappedValue: T {
        get {
            guard let cashedValue = cashed else {
                let resolved = DependependencyContext.current.manager[keyPath: keyPath]
                return resolved
            }
            return cashedValue
        }
        
        set {
            cashed = newValue
        }
    }
}
