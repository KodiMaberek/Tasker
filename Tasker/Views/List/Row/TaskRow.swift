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
    
    var task: MainModel
    
    //MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                CheckMark()
                
                Text(task.value.title)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.labelPrimary)
                    .font(.callout)
                    .onTapGesture {
                        print(vm.selectedDate)
                    }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text("\(Date(timeIntervalSince1970: task.value.notificationDate), format: .dateTime.hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits))")
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
            task.value.taskColor.color(for: colorTheme)
        )
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.success, trigger: vm.taskDone)
    }
    
    //MARK: - Check Mark
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
            if vm.checkCompletedTaskForToday(task: task.value) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tertiary.opacity(0.8))
                    .bold()
            }
        }
        .frame(width: 24, height: 24)
        .onTapGesture {
            vm.checkMarkTapped(task: task)
        }
    }
    
    //MARK: - Play Button
    @ViewBuilder
    private func PlayButton() -> some View {
        Button {
            vm.playButtonTapped(task: task.value)
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
