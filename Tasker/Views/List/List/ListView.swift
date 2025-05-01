//
//  ListView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import SwiftUI

struct ListView: View {
    
    @State private var vm = ListVM()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Text("Tasks")
                        .foregroundStyle(.tertiary.opacity(0.6))
                        .bold()
                    
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    ForEach(vm.latestTasks) { task in
                        Button {
                            vm.selectedTaskButtonTapped(task)
                        } label: {
                            TaskRow(task: task)
                        }
                        .foregroundStyle(.primary)
                        .swipeActions(edge: .trailing) {
                            Button {
                                
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 28)
        }
        .frame(maxHeight: .infinity)
        .scrollIndicators(.hidden)
        .sheet(item: $vm.selectedTask) { task in
            TaskView(task: task)
        }
        .onChange(of: vm.swiftData.update) { _, _ in
            vm.update.toggle()
        }
        .onAppear {
            let tasks = vm.swiftData.fetchAllActiveTask()
            
            for task in tasks {
                print(Date(timeIntervalSince1970: task.notificationDate))
            }
        }
    }
}

#Preview {
    ListView()
}
