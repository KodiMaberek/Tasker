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
    
    var task: TaskModel
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                CheckMark()
                
                Text(task.title)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .onTapGesture {
                        print(vm.selectedDate)
                    }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text("\(Date(timeIntervalSince1970: task.notificationDate), format: .dateTime.hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits))")
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
            task.taskColor.color(for: colorTheme)
        )
        .sensoryFeedback(.success, trigger: vm.taskDone)
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
//            if vm.checkCompletedTaskForToday(task: task) {
//                Image(systemName: "checkmark")
//                    .foregroundStyle(.tertiary.opacity(0.8))
//                    .bold()
//            }
        }
        .frame(width: 24, height: 24)
        .onTapGesture {
            vm.checkMarkTapped(task: task)
        }
    }
    
    @ViewBuilder
    private func PlayButton() -> some View {
        Button {
            vm.playButtonTapped(task: task)
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
    TaskRow(task: mockModel())
}
