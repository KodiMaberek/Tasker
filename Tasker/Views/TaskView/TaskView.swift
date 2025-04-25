//
//  TaskView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var vm = TaskVM()
    
    @State var task: TaskModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                
                VoiceModeToogle()
                
                MainSection()
                
                VStack {
                    DateSelection()
                    
                    TimeSelection()
                    
                    RepeatSelection()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            Color.tertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                        )
                )
                
                Spacer()
            }
            .onAppear {
                vm.onAppear()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .scrollIndicators(.hidden)
        .padding(.horizontal, 16)
        .sensoryFeedback(.selection, trigger: vm.notificationDate)
    }
    
    //MARK: - Voice Toogle
    @ViewBuilder
    private func VoiceModeToogle() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bell")
                .foregroundStyle(elementColor.hexColor())
            
            Toggle(isOn: $task.voiceMode) {
                Text("Play your voice in notification")
                    .font(.system(size: 17, weight: .regular, design: .default))
            }
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.tertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                )
        )
        
    }
    
    //MARK: - Title, Info
    @ViewBuilder
    private func MainSection() -> some View {
        VStack(spacing: 0) {
            TextField("New task", text: $task.title)
                .font(.title2)
                .fontWeight(.semibold)
                .textInputAutocapitalization(.words)
                .foregroundStyle(!task.title.isEmpty ? .primary : Color.gray2)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            
            CustomDivider()
            
            TextField("Add more information", text: $task.info, axis: .vertical)
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundStyle(!task.title.isEmpty ? .primary : Color.gray2)
                .frame(minHeight: 150, alignment: .top)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.tertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                )
        )
    }
    
    //MARK: Date Selector
    @ViewBuilder
    private func DateSelection() -> some View {
        VStack(spacing: 0) {
            Button {
                vm.selectDateButtonTapped()
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "calendar")
                        .tint(elementColor.hexColor())
                    
                    Text("Date")
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 13)
                    
                    Spacer()
                    
                    Text(vm.dateToString())
                        .foregroundStyle(Color.secondary)
                        .opacity(0.80)
                }
            }
            .padding(.leading, 17)
            .padding(.trailing, 14)
            
            CustomDivider()
            
            if vm.showDatePicker {
                DatePicker("", selection: $vm.notificationDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .scrollDismissesKeyboard(.immediately)
                    .id(vm.notificationDate)
                    .tint(elementColor.hexColor())
            }
        }
        .animation(.default, value: vm.showDatePicker)
        .sensoryFeedback(.impact, trigger: vm.showDatePicker)
    }
    
    //MARK: Time Selector
    @ViewBuilder
    private func TimeSelection() -> some View {
        VStack(spacing: 0) {
            Button {
                vm.selectTimeButtonTapped()
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "clock")
                        .tint(elementColor.hexColor())
                    
                    Text("Time")
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 13)
                    
                    
                    Spacer()
                    
                    Text("\(vm.notificationDate, format: .dateTime.hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits))")
                        .foregroundStyle(Color.secondary)
                        .opacity(0.80)
                }
            }
            .padding(.leading, 17)
            .padding(.trailing, 14)
            
            CustomDivider()
            
            if vm.showTimePicker {
                DatePicker("", selection: $vm.notificationDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .tint(elementColor.hexColor())
            }
        }
        .animation(.default, value: vm.showTimePicker)
        .sensoryFeedback(.impact, trigger: vm.showTimePicker)
    }
    
    //MARK: Repeat Selector
    @ViewBuilder
    private func RepeatSelection() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                    .foregroundStyle(elementColor.hexColor())
                
                Text("Repeat")
                    .foregroundStyle(Color.primary)
                    .padding(.vertical, 13)
                
                Spacer()
                
                Picker(selection: $task.repeatTask, content: {
                    ForEach(RepeatTask.allCases, id: \.self) { type in
                        Text("\(type.description)")
                    }
                }, label: {
                    Text("\(task.repeatTask.description)")
                    
                })
                .tint(Color.secondary)
                .opacity(0.80)
                .pickerStyle(.menu)
            }
            .padding(.leading, 17)
            
            CustomDivider()
        }
        .sensoryFeedback(.selection, trigger: task.repeatTask)
    }
    
    //MARK: - Divider
    @ViewBuilder
    private func CustomDivider() -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(
                Color.nonOpaque.opacity(0.34)
            )
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

#Preview {
    TaskView(task: mockModel())
}
