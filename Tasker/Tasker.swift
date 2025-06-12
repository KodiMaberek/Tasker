//
//  Tasker.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/10/25.
//

import SwiftUI

@main
struct Tasker: App {
    @State private var manager = DependenceManager()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(manager)
        }
    }
}
