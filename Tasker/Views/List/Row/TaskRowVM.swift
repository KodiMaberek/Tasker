//
//  TaskRowVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation

@MainActor
@Observable
final class TaskRowVM {
    //MARK: Dependecies
    var playerManager: PlayerProtocol
    var dateManager: DateManagerProtocol
    var casManager: CASManagerProtocol
    
    var playingTask: TaskModel?
    var selectedTask: MainModel?
    
    
    var taskDone = false
    
    //MARK: Computed Properties
    var playing: Bool {
        playerManager.isPlaying
    }
    
    //MARK: Private Properties
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    var selectedDate: Double {
        calendar.startOfDay(for: Date(timeIntervalSince1970: dateManager.selectedDate.timeIntervalSince1970)).timeIntervalSince1970
    }
    
    //MARK: - Init
    init(casManager: CASManagerProtocol) {
        playerManager = PlayerManager()
        dateManager = DateManager.shared
        self.casManager = casManager
    }
    
    //MARK: Selected task
    func selectedTaskButtonTapped(_ task: MainModel) {
        selectedTask = task
    }
    
    //MARK: - Check Mark Function
    func checkMarkTapped(task: MainModel) {
        let newTask = task
        newTask.value.done = updateExistingTaskCompletion(task: newTask.value)
        
        casManager.saveModel(newTask)
        
        taskDone.toggle()
    }
    
    func deleteTaskButtonTapped(task: MainModel) {
        casManager.deleteModel(task)
    }
    
    private func updateExistingTaskCompletion(task: TaskModel) -> [CompleteRecord] {
        var newCompleteRecords: [CompleteRecord] = []
        
        if let existingRecords = task.done {
            
            for record in existingRecords {
                let newRecord = CompleteRecord(
                    completedFor: record.completedFor ?? 0,
                    timeMark: record.timeMark
                )
                newCompleteRecords.append(newRecord)
            }
            
            
            if let indexToRemove = newCompleteRecords.firstIndex(where: { $0.completedFor == selectedDate }) {
                newCompleteRecords.remove(at: indexToRemove)
            } else {
                newCompleteRecords = createNewTaskCompletion(task: task)
            }
        }
        
        return newCompleteRecords
    }
    
    func checkCompletedTaskForToday(task: TaskModel) -> Bool {
        return task.done?.contains(where: { $0.completedFor == selectedDate }) ?? false
    }
    
    func createNewTaskCompletion(task: TaskModel) -> [CompleteRecord] {
        var newCompleteRecords: [CompleteRecord] = []
        
        let newRecord = CompleteRecord(
            completedFor: selectedDate,
            timeMark: Date.now.timeIntervalSince1970
        )
        newCompleteRecords.append(newRecord)
        
        return newCompleteRecords
    }
    
    //MARK: Play sound function
    func playButtonTapped(task: TaskModel) {
        if !playing {
            playerManager.playAudioFromData(task)
            playingTask = task
        } else {
            playerManager.stopToPlay()
            playingTask = nil
        }
    }
}
