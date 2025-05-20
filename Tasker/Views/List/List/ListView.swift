//
//  ListView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import SwiftUI

struct ListView: View {
    
    @State var vm: ListVM
    
    init(casManager: CASManagerProtocol) {
        self.vm = ListVM(casManager: casManager)
    }
    
    var listRowHeight = CGFloat(52)
    
    var body: some View {
        VStack(spacing: 28) {
            TaskList()
            
            CompletedTaskList()
        }
        .sheet(item: $vm.selectedTask) { task in
            TaskView(casManager: vm.casManager, task: task)
        }
        .sensoryFeedback(.selection, trigger: vm.selectedTask)
    }
    
    //MARK: - Task List
    @ViewBuilder
    private func TaskList() -> some View {
        VStack(spacing: 12) {
            if !vm.tasks.isEmpty {
                HStack {
                    Text("Tasks")
                        .foregroundStyle(.tertiary.opacity(0.6))
                        .bold()
                    
                    Spacer()
                }
                
                List {
                    ForEach(vm.tasks) { task in
                        Button {
                            vm.selectedTaskButtonTapped(task)
                        } label: {
                            TaskRow(casManager: vm.casManager, task: task)
                        }
                        .foregroundStyle(.primary)
                        .swipeActions(edge: .trailing) {
                            Button {
                                
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.labelSecondary)
                                    .tint(.red)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .listStyle(.inset)
            }
        }
    }
    
    //MARK: Completed Tasks
    @ViewBuilder
    private func CompletedTaskList() -> some View {
        VStack(spacing: 12) {
            if !vm.completedTasks.isEmpty {
                HStack {
                    Text("Completed task")
                        .foregroundStyle(.tertiary.opacity(0.6))
                        .bold()
                    
                    Spacer()
                }
                
                List {
                    ForEach(vm.completedTasks) { task in
                        Button {
                            vm.selectedTaskButtonTapped(task)
                        } label: {
                            TaskRow(casManager: vm.casManager, task: task)
                        }
                        .foregroundStyle(.primary)
                        .swipeActions(edge: .trailing) {
                            Button {
                                
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.labelSecondary)
                                    .tint(.red)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .listStyle(.inset)
            }
        }
    }
}

#Preview {
    ListView(casManager: CASManager())
}
