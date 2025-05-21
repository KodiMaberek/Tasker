//
//  ListView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import SwiftUI

struct ListView: View {
    @AppStorage("completedTasksHidden") var completedTasksHidden = false
    
    @State var vm: ListVM
    
    init(casManager: CASManagerProtocol) {
        self.vm = ListVM(casManager: casManager)
    }
    
    var body: some View {
        ScrollView {
            TasksList()
            
            CompletedTasksList()
        }
        .animation(.default, value: vm.casManager.models)
        .animation(.default, value: completedTasksHidden)
    }
    
    @ViewBuilder
    private func TasksList() -> some View {
        if !vm.tasks.isEmpty {
            HStack {
                Text("Tasks")
                    .foregroundStyle(.tertiary.opacity(0.6))
                    .bold()
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                ForEach(Array(vm.tasks.enumerated()), id: \.element) { index, task in
                    TaskRow(casManager: vm.casManager, task: task)
                        .foregroundStyle(.primary)
                    
                    if index != vm.tasks.count - 1 {
                        RoundedRectangle(cornerRadius: 0.5)
                            .fill(
                                Color.separatorSecondary.opacity(0.14)
                            )
                            .frame(height: 0.5)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    @ViewBuilder
    private func CompletedTasksList() -> some View {
        if !vm.completedTasks.isEmpty {
            HStack {
                Text("Completed task")
                    .foregroundStyle(.tertiary.opacity(0.6))
                    .bold()
                
                Spacer()
                
                Image(systemName: completedTasksHidden ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.tertiary.opacity(0.6))
                    .bold()
                    .onTapGesture {
                        completedTasksHidden.toggle()
                    }
            }
            .listRowSeparator(.hidden)
            
            if completedTasksHidden {
                VStack(spacing: 0) {
                    ForEach(Array(vm.completedTasks.enumerated()), id: \.element) { index, task in
                        TaskRow(casManager: vm.casManager, task: task)
                            .foregroundStyle(.primary)
                        
                        if index != vm.completedTasks.count - 1 {
                            RoundedRectangle(cornerRadius: 0.5)
                                .fill(
                                    Color.separatorSecondary.opacity(0.14)
                                )
                                .frame(height: 0.5)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

#Preview {
    ListView(casManager: CASManager())
}
