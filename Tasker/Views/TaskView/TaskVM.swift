//
//  TaskVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation
import SwiftUICore

@Observable
final class TaskVM {
    //MARK: - Managers
    @ObservationIgnored
    @Injected(\.casManager) private var casManager: CASManagerProtocol
    @ObservationIgnored
    @Injected(\.playerManager) private var playerManager: PlayerManagerProtocol
    @ObservationIgnored
    @Injected(\.recorderManager) private var recorderManager: RecorderManagerProtocol
    @ObservationIgnored
    @Injected(\.dateManager) private var dateManager: DateManagerProtocol
    @ObservationIgnored
    @Injected(\.taskManager) private var taskManager
    
    //MARK: Model
    var mainModel: MainModel = mockModel()
    var task: TaskModel = mockModel().value
    
    //MARK: UI States
    var showDatePicker = false
    var showTimePicker = false
    var shareViewIsShowing = false
    var taskDoneTrigger = false
    
    var playButtonTrigger = false
    var sliderValue = 0.0
    var isDragging = false
    
    //MARK: Confirmation dialog
    var confirmationDialogIsPresented = false
    var messageForDelete = ""
    var singleTask = true
    
    //MARK: - Computed properties
    var calendar: Calendar {
        dateManager.calendar
    }
    
    var notificationDate = Date() {
        didSet {
            checkTimeAfterSelected()
        }
    }
    
    var dateForAppearence: String {
        dateToString()
    }
    
    // Playing
    var currentProgressTime: TimeInterval {
        playerManager.currentTime
    }
    
    var totalProgressTime: TimeInterval {
        playerManager.totalTime
    }
    
    // Recording
    var isRecording: Bool {
        recorderManager.isRecording
    }
    
    var decibelLVL: Float {
        recorderManager.decibelLevel
    }
    
    @ObservationIgnored
    var color = Color.black {
        didSet {
            task.taskColor = .custom(color.toHex())
        }
    }
    
    private var originalNotificationTimeComponents: DateComponents {
        calendar.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: task.notificationDate))
    }
    
    //MARK: - Private properties
    private var lastChangeTime = Date()
    private var debounceTimer: Timer?
    private var lastNotificationDate = Date()
    
    //MARK: - Init
    init(mainModel: MainModel) {
        self.mainModel = mainModel
        task = mainModel.value
        
        let time = originalNotificationTimeComponents
        notificationDate = combineDateAndTime(timeComponents: time)
    }
    
    func selectDateButtonTapped() {
        showDatePicker.toggle()
    }
    
    func selectTimeButtonTapped() {
        showTimePicker.toggle()
    }
    
    func selectedColorButtonTapped(_ taskColor: TaskColor) {
        task.taskColor = taskColor
    }
    
    func shareViewButtonTapped() {
        shareViewIsShowing.toggle()
    }
    
    //MARK: - Save Button
    func saveTask() {
        task = preparedTask()
        mainModel.value = task
        casManager.saveModel(mainModel)
    }
    
    private func preparedTask() -> TaskModel {
        return taskManager.preparedTask(task: task, date: notificationDate)
    }
    
    private func dateToString() -> String {
        dateManager.dateToString(for: notificationDate, format: "MMMM d", useForWeekView: false)
    }
    
    private func combineDateAndTime(timeComponents: DateComponents) -> Date {
        dateManager.combineDateAndTime(timeComponents: timeComponents)
    }
    
    private func dateHasBeenSelected() {
        showDatePicker = false
        showTimePicker = false
    }
    
    private func checkTimeAfterSelected() {
        debounceTimer?.invalidate()
        
        lastChangeTime = Date()
        
        let calendar = Calendar.current
        let oldComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: lastNotificationDate)
        let newComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: notificationDate)
        
        let timeInterval: TimeInterval
        
        if oldComponents.day != newComponents.day ||
            oldComponents.month != newComponents.month ||
            oldComponents.year != newComponents.year {
            
            timeInterval = 0.1
        } else {
            timeInterval = 0.8
        }
        
        lastNotificationDate = notificationDate
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                if let self = self, Date().timeIntervalSince(self.lastChangeTime) >= timeInterval {
                    self.dateHasBeenSelected()
                }
            }
        }
    }
    
    //MARK: - Check Mark Function
    func checkCompletedTaskForToday() -> Bool {
        taskManager.checkCompletedTaskForToday(task: task)
    }
    
    func checkMarkTapped() {
        task = taskManager.checkMarkTapped(task: mainModel).value
        taskDoneTrigger.toggle()
        saveTask()
    }
    
    //MARK: - Delete functions
    func deleteTaskButtonTapped() {
        guard task.repeatTask == .never else {
            messageForDelete = "This's a recurring task."
            singleTask = false
            confirmationDialogIsPresented.toggle()
            return
        }
        
        messageForDelete = "Delete this task?"
        singleTask = true
        confirmationDialogIsPresented.toggle()
    }
    
    func deleteButtonTapped(model: MainModel, deleteCompletely: Bool = false) {
        task = taskManager.deleteTask(task: model, deleteCompletely: deleteCompletely).value
        saveTask()
    }
    
    //MARK: Playing function
    func playButtonTapped(task: TaskModel) async {
        playButtonTrigger.toggle()
        
        guard playerManager.isPlaying == false else {
            stopToPlay()
            return
        }
        var data: Data?
        
        if let audio = task.audio {
            data = casManager.getData(audio)
            
            if let data = data {
                await playerManager.playAudioFromData(data, task: task)
            }
        }
    }
    
    private func stopToPlay() {
        playerManager.stopToPlay()
    }
    
    func seekAudio(_ time: TimeInterval) {
        playerManager.seekAudio(time)
    }
    
    func currentTimeString() -> String {
        let minutes = Int(currentProgressTime) / 60
        let seconds = Int(currentProgressTime) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func checkIsPlaying() -> Bool {
        playerManager.isPlaying
    }
    
    //MARK: - Record functions
    func recordButtonTapped() async {
        if isRecording {
            stopRecord()
        } else {
            await startRecord()
        }
    }
    
    private func startRecord() async {
        await recorderManager.startRecording()
    }
    
    private func stopRecord() {
        var hashOfAudio: String?
        
        if let audioURLString = recorderManager.stopRecording() {
            hashOfAudio = casManager.saveAudio(url: audioURLString)
        }
        
        task.audio = hashOfAudio
    }
}
