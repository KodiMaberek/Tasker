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

protocol DependencyRegistry {
    var manager: DependenceManagerProtocol { get }
}

enum DependencyContext {
    private static var _current: DependencyRegistry = DefaultRegistry()
    
    static var current: DependencyRegistry {
        get { _current }
        set { _current = newValue }
    }
    
    private struct DefaultRegistry: DependencyRegistry {
        let manager: DependenceManagerProtocol = DependenceManager()
    }
}

@propertyWrapper
final class Injected<T> {
    private let keyPath: KeyPath<DependenceManagerProtocol, T>
    private var cached: T?

    init(_ keyPath: KeyPath<DependenceManagerProtocol, T>) {
        self.keyPath = keyPath
    }

    var wrappedValue: T {
        get {
            if let cached = cached {
                return cached
            }
            let resolved = DependencyContext.current.manager[keyPath: keyPath]
            cached = resolved
            return resolved
        }
        set {
            cached = newValue
        }
    }
}


