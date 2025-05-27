//
//  MainView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/11/25.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var vm = MainVM()
    
    @State private var isPressed: Bool = false
    @State private var isRecording = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme.backgroundColor.hexColor())
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    WeekView()
                    
                    ListView(casManager: vm.casManager)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .bottom)
                
                VStack {
                    
                    Spacer()
                    
                    RecordButton(isRecording: $vm.isRecording, progress: vm.progress, countOfSec: vm.currentlyTime, animationAmount: vm.decibelLvl) {
                        vm.stopRecord()
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.2).onEnded({ _ in
                            Task {
                                try await vm.startAfterChek()
                            }
                        })
                    )
                    .padding(.bottom, 15)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(colorScheme.elementColor.hexColor())
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    TextField("", text: $vm.textForYourSelf)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundStyle(colorScheme.elementColor.hexColor())
                    }
                }
            }
            .onChange(of: vm.currentlyTime) { newValue, oldValue in
                if newValue > 15.0 {
                    vm.stopRecord()
                }
            }
            .sheet(item: $vm.model) { model in
                TaskView(casManager: vm.casManager, task: model)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: vm.isRecording)
    }
}

#Preview {
    MainView()
}
