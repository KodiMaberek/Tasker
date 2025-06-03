//
//  TaskRow.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import SwiftUI

struct TaskRow: View {
    @Environment(\.colorScheme) var colorTheme
    @State var vm: TaskRowVM
    
    var task: MainModel
    
    init(casManager: CASManagerProtocol, playerManager: PlayerProtocol, task: MainModel) {
        self.vm = TaskRowVM(casManager: casManager, playerManager: playerManager)
        self.task = task
    }
    
    //MARK: - Body
    var body: some View {
        FinalTaskRow()
            .sheet(item: $vm.selectedTask) { task in
                TaskView(casManager: vm.casManager, task: task)
            }
            .confirmationDialog("", isPresented: $vm.confirmationDialogIsPresented) {
                if vm.singleTask {
                    Button(role: .destructive) {
                        vm.deleteButtonTapped(task: task, deleteCompletely: true)
                    } label: {
                        Text("Delete this task")
                    }
                } else {
                    Button(role: .destructive) {
                        vm.deleteButtonTapped(task: task)
                    } label: {
                        Text("Delete only this task")
                    }
                    
                    Button {
                        vm.deleteButtonTapped(task: task, deleteCompletely: true)
                    } label: {
                        Text("Delete all of these tasks")
                    }
                }
            } message: {
                Text(vm.messageForDelete)
            }
            .sensoryFeedback(.selection, trigger: vm.selectedTask)
            .sensoryFeedback(.success, trigger: vm.taskDone)
    }
    
    @ViewBuilder
    private func FinalTaskRow() -> some View {
        List {
            ForEach(0..<1) { _ in
                HStack(spacing: 0) {
                    HStack(spacing: 12) {
                        CheckMark()
                        
                        Text(task.value.title)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.labelPrimary)
                            .font(.callout)
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
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectedTaskButtonTapped(task)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 11)
                .background(
                    task.value.taskColor.color(for: colorTheme)
                )
                .frame(maxWidth: .infinity)
                .sensoryFeedback(.success, trigger: vm.taskDone)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    vm.deleteTaskButtonSwiped(task: task)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.labelSecondary)
                        .tint(.red)
                }
            }
        }
        .listStyle(PlainListStyle())
        .listRowSeparator(.hidden)
        .frame(height: vm.listRowHeight)
        .scrollDisabled(true)
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
        ZStack {
            Circle()
                .fill(
                    .tertiary.opacity(0.2)
                )
            
            if task.value.audio != nil {
                Image(systemName: vm.playing ? "pause.fill" : "play.fill")
                    .foregroundStyle(.white)
                    .animation(.default, value: vm.playing)
            } else {
                Image(systemName: "plus").bold()
                    .foregroundStyle(.white)
                    .animation(.default, value: vm.playing)
            }
        }
        .frame(width: 28, height: 28)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            Task {
                await vm.playButtonTapped(task: task)
            }
        }
    }
}

#Preview {
    TaskRow(casManager: CASManager(), playerManager: PlayerManager(), task: mockModel())
}
