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
    var listRowHeight = CGFloat(52)
    
    //MARK: Confirmation dialog
    var confirmationDialogIsPresented = false
    var messageForDelete = ""
    var singleTask = true
    
    //MARK: Computed Properties
    var playing: Bool {
        playerManager.isPlaying
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
