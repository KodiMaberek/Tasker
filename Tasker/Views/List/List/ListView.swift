//
//  ListView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import SwiftUI

struct ListView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("completedTasksHidden") var completedTasksHidden = false
    
    @State var vm: ListVM
    
    init(casManager: CASManagerProtocol) {
        self.vm = ListVM(casManager: casManager)
    }
    
    var body: some View {
        ScrollView {
            TasksList()
            
            if vm.completedTasks.isEmpty {
                GeometryReader { geometry in
                    Color.clear
                        .frame(height: max(geometry.size.height, 400))
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { _ in
                                    if !vm.startSwipping {
                                        vm.startSwipping = true
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.width < -50 {
                                        vm.nextDaySwiped()
                                    } else if value.translation.width > 50 {
                                        vm.previousDaySwiped()
                                    }
                                    vm.startSwipping = false
                                }
                        )
                        .onTapGesture(count: 2) {
                            vm.backToTodayButtonTapped()
                        }
                }
            }
            
            CompletedTasksList()
            
            GeometryReader { geometry in
                Color.clear
                    .frame(height: max(geometry.size.height, 400))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    vm.nextDaySwiped()
                                } else if value.translation.width > 50 {
                                    vm.previousDaySwiped()
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        vm.backToTodayButtonTapped()
                    }
            }
        }
        .customBlurForContainer(colorScheme: colorScheme)
        .scrollIndicators(.hidden)
        .scrollDisabled(vm.startSwipping)
        .animation(.linear, value: completedTasksHidden)
        .sensoryFeedback(.impact, trigger: completedTasksHidden)
    }
    
    @ViewBuilder
    private func TasksList() -> some View {
        if !vm.tasks.isEmpty {
            HStack {
                Text("Tasks")
                    .foregroundStyle(.labelTertiary.opacity(0.6))
                    .bold()
                
                Spacer()
            }
            .padding(.top, 18)
            .padding(.bottom, 12)
            
            VStack(spacing: 0) {
                ForEach(Array(vm.tasks.enumerated()), id: \.element) { index, task in
                    TaskRow(casManager: vm.casManager, playerManager: vm.playerManager, task: task)
                        .foregroundStyle(.primary)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
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
                    .foregroundStyle(.labelTertiary.opacity(0.6))
                    .bold()
                
                Spacer()
                
                Image(systemName: completedTasksHidden ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.tertiary.opacity(0.6))
                    .bold()
                    .onTapGesture {
                        completedTasksHidden.toggle()
                    }
            }
            .padding(.top, 18)
            .padding(.bottom, 12)
            
            
            if completedTasksHidden {
                VStack(spacing: 0) {
                    ForEach(Array(vm.completedTasks.enumerated()), id: \.element) { index, task in
                        TaskRow(casManager: vm.casManager, playerManager: vm.playerManager, task: task)
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
