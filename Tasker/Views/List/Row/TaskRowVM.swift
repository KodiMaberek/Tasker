//
//  TaskRowVM.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation

@Observable
final class TaskRowVM {
    //MARK: Dependecies
    @ObservationIgnored
    @Injected(\.playerManager) private var playerManager: PlayerManagerProtocol
    @ObservationIgnored
    @Injected(\.dateManager) private var dateManager: DateManagerProtocol
    @ObservationIgnored
    @Injected(\.casManager) private var casManager: CASManagerProtocol
    
    
    //MARK: - Properties
    var playingTask: TaskModel?
    var selectedTask: MainModel?
    
    //MARK: - UI States
    var taskDone = false
    var listRowHeight = CGFloat(52)
    var startPlay = false
    
    //MARK: Confirmation dialog
    var confirmationDialogIsPresented = false
    var messageForDelete = ""
    var singleTask = true
    
    //MARK: Computed Properties
    var playing: Bool {
        playerManager.isPlaying && playerManager.task?.id == playingTask?.id
    }
    
    //MARK: Private Properties
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: Date(timeIntervalSince1970: dateManager.selectedDate.timeIntervalSince1970)).timeIntervalSince1970
    }
    
    private var nowDate: Double {
        Date.now.timeIntervalSince1970
    }
    
    //MARK: Selected task
    func selectedTaskButtonTapped(_ task: MainModel) {
        selectedTask = task
        stopToPlay()
    }
    
    //MARK: - Check Mark Function
    func checkMarkTapped(task: MainModel) {
        let newTask = task
        newTask.value.done = updateExistingTaskCompletion(task: newTask.value)
        
        casManager.saveModel(newTask)
        
        taskDone.toggle()
        stopToPlay()
    }
    
    func checkCompletedTaskForToday(task: TaskModel) -> Bool {
        return task.done?.contains(where: { $0.completedFor == selectedDate }) ?? false
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
                newCompleteRecords.append(createNewTaskCompletion(task: task))
            }
        }
        else {
            newCompleteRecords.append(createNewTaskCompletion(task: task))
        }
        
        return newCompleteRecords
    }
    
    private func createNewTaskCompletion(task: TaskModel) -> CompleteRecord {
        CompleteRecord(completedFor: selectedDate,timeMark: nowDate)
    }
    
    //MARK: - Delete functions
    func deleteTaskButtonSwiped(task: MainModel) {
        guard task.value.repeatTask == .never else {
            messageForDelete = "This's a recurring task."
            singleTask = false
            confirmationDialogIsPresented.toggle()
            return
        }
        
        messageForDelete = "Delete this task?"
        singleTask = true
        confirmationDialogIsPresented.toggle()
    }
    
    func deleteButtonTapped(task: MainModel, deleteCompletely: Bool = false) {
        guard task.value.markAsDeleted == false else { return }
        
        let newTask = task
        
        if deleteCompletely == true {
            newTask.value.markAsDeleted = true
        } else {
            newTask.value.deleted = updateExistingTaskDeleted(task: newTask.value)
        }
        
        casManager.saveModel(newTask)
    }
    
    private func updateExistingTaskDeleted(task: TaskModel) -> [DeleteRecord] {
        var newDeletedRecords: [DeleteRecord] = []
        
        if let deletedRecord = task.deleted {
            newDeletedRecords = deletedRecord
            newDeletedRecords.append(DeleteRecord(deletedFor: selectedDate, timeMark: nowDate))
        } else {
            newDeletedRecords.append(DeleteRecord(deletedFor: selectedDate, timeMark: nowDate))
        }
        
        return newDeletedRecords
    }
    
    //MARK: Play sound function
    func playButtonTapped(task: MainModel) async {
        var data: Data?
        
        if let audio = task.value.audio {
            data = casManager.getData(audio)
            
            if !playing {
                if let data = data {
                    playingTask = task.value
                    await playerManager.playAudioFromData(data, task: task.value)
                }
            } else {
                stopToPlay()
            }
        } else {
            selectedTask = task
        }
    }
    
    private func stopToPlay() {
        playerManager.stopToPlay()
        playingTask = nil
    }
}
