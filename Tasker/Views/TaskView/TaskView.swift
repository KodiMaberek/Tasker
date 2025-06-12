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
    @Environment(\.dependencies) var manager
    
    @State private var vm = TaskVM()
    
    var mainModel: MainModel
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [vm.task.taskColor.color(for: colorScheme), colorScheme.backgroundColor.hexColor()], startPoint: .bottom, endPoint: .top)
                .opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                CustomTabBar()
                
                ScrollView {
                    VStack(spacing: 28) {
                        
                        VStack(spacing: 28) {
                            if vm.task.audio != nil {
                                VoicePlaying()
                                
                                VoiceModeToogle()
                            } else {
                                AddVoice()
                            }
                        }
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
                                    Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                                )
                        )
                        
                        CustomColorPicker()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                                    )
                            )
                        
                        CreatedDate()
                        
                        Spacer()
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
                
                SaveButton()
                
            }
            .onAppear {
                vm.onAppear(mainModel: mainModel, manager: manager)
            }
            .sensoryFeedback(.selection, trigger: vm.notificationDate)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: vm.playButtonTrigger)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: vm.isRecording)
            .animation(.default, value: vm.task.audio)
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
                    .foregroundStyle(.accentRed)
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
    
    //MARK: Voice Playing
    @ViewBuilder
    private func VoicePlaying() -> some View {
        HStack(spacing: 12) {
            Image(systemName: vm.checkIsPlaying() ? "pause" : "play")
                .frame(width: 21, height: 21)
                .onTapGesture {
                    Task {
                        await vm.playButtonTapped(task: vm.task)
                    }
                }
            
            Slider(
                value: Binding(
                    get: {
                        vm.isDragging ? vm.sliderValue : vm.currentProgressTime
                    },
                    set: { newValue in
                        vm.sliderValue = newValue
                        if !vm.isDragging {
                            vm.seekAudio(newValue)
                        }
                    }
                ),
                in: 0...vm.totalProgressTime,
                onEditingChanged: { editing in
                    if editing {
                        vm.isDragging = true
                    } else {
                        vm.isDragging = false
                        vm.seekAudio(vm.sliderValue)
                    }
                }
            )
            .tint(colorScheme.elementColor.hexColor())
            
            Text(vm.currentTimeString())
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundStyle(.labelPrimary)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                )
        )
        .animation(.default, value: vm.currentProgressTime)
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
                    .foregroundStyle(.labelPrimary)
            }
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                )
        )
    }
    
    //MARK: - Add Voice
    @ViewBuilder
    private func AddVoice() -> some View {
        HStack(spacing: 12) {
            if vm.isRecording {
                EqualizerView(decibelLevel: vm.decibelLVL)
            } else {
                Text("Add voice recording")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(.labelPrimary)
            }
            
            Spacer()
            
            Button {
                Task {
                    await vm.recordButtonTapped()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            colorScheme.elementColor.hexColor()
                        )
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: vm.isRecording ? "pause.fill" : "microphone.fill")
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
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
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
            
            CustomDivider()
            
            VStack {
                TextField("Add more information", text: $vm.task.info, axis: .vertical)
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .frame(minHeight: 70, alignment: .top)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color.labelTertiary.opacity(colorScheme == .dark ? 0.08 : 0.04)
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
            Text("Close")
                .foregroundStyle(.white)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            colorScheme.elementColor.hexColor()
                        )
                )
                .padding(.top, 8)
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
    
    //MARK: - Created Date
    @ViewBuilder
    private func CreatedDate() -> some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .foregroundStyle(.labelTertiary).opacity(0.6)
            
            Text("Created:")
                .foregroundStyle(.labelTertiary).opacity(0.6)
            
            Text(Date(timeIntervalSince1970:vm.task.createDate).formatted(.dateTime.month().day().hour().minute().year()))
                .foregroundStyle(.labelTertiary)
            
        }
    }
}

#Preview {
    TaskView(mainModel: mockModel())
}
