//
//  TaskRow.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import SwiftUI

struct TaskRow: View {
    @Environment(\.colorScheme) var colorTheme
    @State private var vm = TaskRowVM()
    
    @Binding var model: TaskModel
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                CheckMark()
                
                Text(model.title)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text("\(Date.now, format: .dateTime.hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits))")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary.opacity(0.6))
                    .padding(.leading, 16)
                    .lineLimit(1)
                
                PlayButton()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 11)
        .background(
            model.taskColor.color(for: colorTheme)
        )
        .padding(.horizontal, 16)
        .animation(.default, value: model.done)
    }
    
    @ViewBuilder
    private func CheckMark() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    Color.tertiary.opacity(0.04)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.black.opacity(0.20), lineWidth: 1)
                )
            if ((model.done?.done) != nil) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tertiary.opacity(0.8))
                    .bold()
            }
        }
        .frame(width: 24, height: 24)
        .onTapGesture {
            vm.checkMarkTapped(model: model)
        }
    }
    
    @ViewBuilder
    private func PlayButton() -> some View {
        Button {
            vm.playButtonTapped(task: model)
        } label: {
            ZStack {
                Circle()
                    .fill(
                        .tertiary.opacity(0.2)
                    )
                
                Image(systemName: vm.playing ? "pause.fill" : "play.fill")
                    .foregroundStyle(.white)
            }
            .frame(width: 28, height: 28)
        }
    }
}

#Preview {
    TaskRow(model: .constant(mockModel()))
}
