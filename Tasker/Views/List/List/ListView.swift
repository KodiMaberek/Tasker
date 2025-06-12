//
//  ListView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/26/25.
//

import SwiftUI

struct ListView: View {
    @Environment(\.dependencies) var manager
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("completedTasksHidden") var completedTasksHidden = false
    
    @State private var vm = ListVM()
    
    var body: some View {
        GeometryReader { screenGeometry in
            ScrollView {
                VStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        TasksList()
                        
                        CompletedTasksList()
                    }
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .preference(
                                    key: ContentHeightPreferenceKey.self,
                                    value: contentGeometry.size.height
                                )
                        }
                    )
                    
                    GestureDetectView()
                        .frame(height: vm.calculateGestureViewHeight(
                            screenHeight: screenGeometry.size.height,
                            contentHeight: vm.contentHeight,
                            safeAreaTop: screenGeometry.safeAreaInsets.top,
                            safeAreaBottom: screenGeometry.safeAreaInsets.bottom
                        ))
                }
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(vm.startSwipping)
            .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                vm.contentHeight = height
            }
        }
        .onAppear {
            vm.onAppear(manager: manager)
        }
        .customBlurForContainer(colorScheme: colorScheme)
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
                    TaskRow(task: task)
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
                        TaskRow(task: task)
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
    
    //MARK: Gesture dectectView
    @ViewBuilder
    private func GestureDetectView() -> some View {
        Color.clear
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
                        
                        if value.translation.height < -10 {
                            print("down")
                        } else if value.translation.height > 10 {
                            print("up")
                        }
                        vm.startSwipping = false
                    }
            )
            .onTapGesture(count: 2) {
                vm.backToTodayButtonTapped()
            }
    }
}

#Preview {
    ListView()
}


struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
