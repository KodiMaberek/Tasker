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
    var cas: CASManagerProtocol
    
    var playingTask: TaskModel?
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
    init() {
        playerManager = PlayerManager()
        dateManager = DateManager.shared
        cas = CASManager()
    }
    
    //MARK: - Check Mark Function
    func checkMarkTapped(task: TaskModel) {
        // Task's clone
        var newTask = TaskModel(id: task.id, title: task.title, info: task.info, createDate: task.createDate)
        newTask.audio = task.audio
        newTask.endDate = task.endDate
        newTask.notificationDate = task.notificationDate
        newTask.secondNotificationDate = task.secondNotificationDate
        newTask.voiceMode = task.voiceMode
        newTask.repeatTask = task.repeatTask
        newTask.dayOfWeek = task.dayOfWeek
        
        // Update completion record
        newTask.done 
        newTask.deleted = task.deleted
        
        newTask.taskColor = task.taskColor
        
        
        taskDone.toggle()
    }
    
//    private func updateExistingTaskCompletion(task: TaskModel) -> [CompleteRecord] {
//        print("update existing")
//        var newCompleteRecords: [CompleteRecord] = []
//        
//        if let existingRecords = task.done {
//            
//            for record in existingRecords {
//                let newRecord = CompleteRecord(
//                    task: task,
//                    done: record.done,
//                    completedFor: record.completedFor ?? 0,
//                    timeMark: record.timeMark
//                )
//                newCompleteRecords.append(newRecord)
//            }
//            
//            
//            if let indexToRemove = newCompleteRecords.firstIndex(where: { $0.completedFor == selectedDate }) {
//                newCompleteRecords.remove(at: indexToRemove)
//            } else {
//                newCompleteRecords = createNewTaskCompletion(task: task)
//            }
//        }
//        
//        return newCompleteRecords
//    }
//    
//    func checkCompletedTaskForToday(task: TaskModel) -> Bool {
//        return task.done?.contains(where: { $0.completedFor == selectedDate }) ?? false
//    }
    
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
