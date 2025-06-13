//
//  View+Ext.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/22/25.
//

import Foundation
import SwiftUICore

extension View {
    func customBlurForContainer(colorScheme: ColorScheme) -> some View {
        self
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [colorScheme.backgroundColor.hexColor(), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 30)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, colorScheme.backgroundColor.hexColor()],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .bottom)
                .frame(height: 100)
                .allowsHitTesting(false)
            }
    }
    
    /// Confirmation dialog
    func taskDeleteDialog(isPresented: Binding<Bool>, task: MainModel, message: String, isSingleTask: Bool, onDelete: @escaping (MainModel, Bool) -> Void) -> some View {
        modifier(
            TaskDeleteDialog(
                isPresented: isPresented,
                task: task,
                message: message,
                isSingleTask: isSingleTask,
                onDelete: onDelete
            )
        )
    }
}
