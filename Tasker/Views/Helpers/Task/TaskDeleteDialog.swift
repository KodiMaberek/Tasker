//
//  TaskDeleteDialog.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 6/12/25.
//

import SwiftUI

struct TaskDeleteDialog: ViewModifier {
    @Environment(\.dismiss) var dismissButton
    
    @Binding var isPresented: Bool
    
    let task: MainModel
    let message: String
    let isSingleTask: Bool
    let onDelete: (MainModel, Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog("", isPresented: $isPresented) {
                if isSingleTask {
                    Button(role: .destructive) {
                        Task {
                            dismissButton()
                            
                            try await Task.sleep(nanoseconds: 50_000_000)
                            onDelete(task, true)
                        }
                    } label: {
                        Text("Delete this task")
                    }
                } else {
                    Button(role: .destructive) {
                        Task {
                            dismissButton()
                            
                            try await Task.sleep(nanoseconds: 50_000_000)
                            onDelete(task, false)
                        }
                    } label: {
                        Text("Delete only this task")
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            dismissButton()
                            
                            try await Task.sleep(nanoseconds: 50_000_000)
                            onDelete(task, true)
                        }
                    } label: {
                        Text("Delete all of these tasks")
                    }
                }
            } message: {
                Text(message)
            }
    }
}


