//
//  TaskCheckMark.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 6/12/25.
//

import SwiftUI

struct TaskCheckMark: View {
    var complete: Bool
    var action: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    Color.labelTertiary.opacity(0.04)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.black.opacity(0.20), lineWidth: 1)
                )
            if complete {
                Image(systemName: "checkmark")
                    .foregroundStyle(.labelTertiary.opacity(0.8))
                    .bold()
            }
        }
        .frame(width: 24, height: 24)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    TaskCheckMark(complete: true, action: {})
}
