//
//  TaskView.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismissButton
    
    @State private var vm: TaskVM
    
    init(casManager: CASManagerProtocol, task: MainModel) {
        self.vm = TaskVM(mainModel: task, casManager: casManager)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [vm.task.taskColor.color(for: colorScheme), colorScheme.backgroundColor.hexColor()], startPoint: .bottom, endPoint: .top)
                .opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomTabBar()
                
                ScrollView {
                    VStack(spacing: 28) {
                        
                        VoiceModeToogle()
                            .padding(.top, 12)
                        
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
                        
                        CustomColorPicker()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        Color.tertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                                    )
                            )
                        
                        Spacer()
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .scrollIndicators(.hidden)
                
                SaveButton()
                
            }
            .onAppear {
                vm.onAppear()
            }
            .sensoryFeedback(.selection, trigger: vm.notificationDate)
            .sheet(isPresented: $vm.shareViewIsShowing) {
                ShareView(activityItems: [vm.task])
                    .presentationDetents([.medium])
            }
            .padding(.horizontal, 16)
        }
    }
    
    //MARK: TabBar
    @ViewBuilder
    private func CustomTabBar() -> some View {
        HStack(alignment: .center) {
            Button {
                dismissButton()
            } label: {
                Text("Cancel")
            }
            
            Spacer()
            
            Button {
                vm.shareViewButtonTapped()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .padding(.vertical, 11)
        }
        .tint(colorScheme.elementColor.hexColor())
        .padding(.top, 14)
        .padding(.bottom, 3)
    }
    
    //MARK: - Voice Toogle
    @ViewBuilder
    private func VoiceModeToogle() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bell")
                .foregroundStyle(colorScheme.elementColor.hexColor())
            
            Toggle(isOn: $vm.task.voiceMode) {
                Text("Play your voice in notification")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(.primary)
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
            TextField("New task", text: $vm.task.title)
                .font(.title2)
                .fontWeight(.semibold)
                .textInputAutocapitalization(.words)
                .foregroundStyle(!vm.task.title.isEmpty ? .primary : Color.gray2)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            
            CustomDivider()
            
            TextField("Add more information", text: $vm.task.info, axis: .vertical)
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundStyle(!vm.task.title.isEmpty ? .primary : Color.gray2)
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
                withAnimation(.easeInOut(duration: vm.showDatePicker == false ? 0 : 0.2)) {
                    vm.selectDateButtonTapped()
                }
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "calendar")
                        .foregroundStyle(colorScheme.elementColor.hexColor())
                    
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
                DatePicker("", selection: $vm.notificationDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .scrollDismissesKeyboard(.immediately)
                    .id(vm.notificationDate)
                    .tint(colorScheme.elementColor.hexColor())
            }
        }
        .sensoryFeedback(.impact, trigger: vm.showDatePicker)
    }
    
    //MARK: Time Selector
    @ViewBuilder
    private func TimeSelection() -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: vm.showTimePicker == false ? 0 : 0.2)) {
                    vm.selectTimeButtonTapped()
                }
            } label: {
                HStack(spacing: 13) {
                    Image(systemName: "clock")
                        .foregroundStyle(colorScheme.elementColor.hexColor())
                    
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
                    .tint(colorScheme.elementColor.hexColor())
            }
        }
        .sensoryFeedback(.impact, trigger: vm.showTimePicker)
    }
    
    //MARK: Repeat Selector
    @ViewBuilder
    private func RepeatSelection() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                    .foregroundStyle(colorScheme.elementColor.hexColor())
                
                Text("Repeat")
                    .foregroundStyle(Color.primary)
                    .padding(.vertical, 13)
                
                Spacer()
                
                Picker(selection: $vm.task.repeatTask, content: {
                    ForEach(RepeatTask.allCases, id: \.self) { type in
                        Text("\(type.description)")
                    }
                }, label: {
                    HStack {
                        Text("\(vm.task.repeatTask.description)")
                    }
                })
                .tint(Color.secondary)
                .opacity(0.80)
                .pickerStyle(.menu)
            }
            .padding(.leading, 17)
            
            if vm.task.repeatTask == .dayOfWeek {
                DayOfWeekSelection()
            }
        }
        .sensoryFeedback(.selection, trigger: vm.task.repeatTask)
    }
    
    @ViewBuilder
    private func DayOfWeekSelection() -> some View {
        VStack(spacing: 0) {
            
            CustomDivider()
            
            HStack {
                ForEach($vm.task.dayOfWeek) { $day in
                    Button {
                        day.value.toggle()
                    } label: {
                        Text(day.name)
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .foregroundStyle(day.value ? colorScheme.elementColor.hexColor() : .labelSecondary.opacity(0.8))
                            .padding(.vertical, 13)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.labelSecondary.opacity(0.8))
                
                Text("Pick the days of the week to repeat")
                    .foregroundStyle(.labelSecondary.opacity(0.8))
            }
            .padding(.bottom, 13)
        }
        .sensoryFeedback(.selection, trigger: vm.task.dayOfWeek)
    }
    
    //MARK: ColorPicker
    @ViewBuilder
    private func CustomColorPicker() -> some View {
        VStack {
            HStack {
                Text("Color task")
                    .foregroundStyle(.labelSecondary.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 17)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(TaskColor.allCases, id: \.id) { color in
                        Button {
                            vm.selectedColorButtonTapped(color)
                        } label: {
                            Circle()
                                .fill(color.color(for: colorScheme))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.separatorPrimary.opacity(0.24), lineWidth: vm.task.taskColor.id == color.id ? 1.5 : 0.3)
                                        .shadow(radius: 8, y: 4)
                                )
                        }
                    }
                    
                    ColorPicker("", selection: $vm.color)
                        .padding(.leading, -10)
                }
                .padding(.horizontal, 17)
                .padding(.vertical, 1)
            }
            .sensoryFeedback(.selection, trigger: vm.task.taskColor)
        }
        .padding(.vertical, 13)
    }
    
    //MARK: Save button
    @ViewBuilder
    private func SaveButton() -> some View {
        Button {
            dismissButton()
            vm.doneButtonTapped()
        } label: {
            Text("Done")
                .foregroundStyle(.white)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            colorScheme.elementColor.hexColor()
                        )
                )
                .padding(.bottom)
        }
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
    TaskView(casManager: CASManager(), task: mockModel())
}
