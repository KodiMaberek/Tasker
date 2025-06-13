//
//  TaskManager.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/14/25.
//

import Foundation

@Observable
final class TaskManager: TaskManagerProtocol {
    @ObservationIgnored
    @Injected(\.casManager) private var casManager
    @ObservationIgnored
    @Injected(\.dateManager) private var dateManager
    
    //MARK: Computer properties
    private var calendar: Calendar {
        dateManager.calendar
    }
    
    private var selectedDate: Double {
        calendar.startOfDay(for: Date(timeIntervalSince1970: dateManager.selectedDate.timeIntervalSince1970)).timeIntervalSince1970
    }
    
    private var nowDate: Double {
        dateManager.currentTime.timeIntervalSince1970
    }
    
    func preparedTask(task: TaskModel, date: Date) -> TaskModel {
        var filledTask = TaskModel(id: task.id, title: task.title.isEmpty ? "New Task" : task.title, info: task.info, createDate: task.createDate)
        filledTask.notificationDate = date.timeIntervalSince1970
        filledTask.done = task.done
        filledTask.taskColor = task.taskColor
        filledTask.repeatTask = task.repeatTask
        filledTask.audio = task.audio
        filledTask.voiceMode = task.voiceMode
        filledTask.deleted = task.deleted
        filledTask.markAsDeleted = task.markAsDeleted
        filledTask.endDate = task.endDate
        filledTask.secondNotificationDate = task.secondNotificationDate
        filledTask.dayOfWeek = task.dayOfWeek
        
        return filledTask
    }
    
    //MARK: - Completed functions
    /// Check completed task for today or not
    func checkCompletedTaskForToday(task: TaskModel) -> Bool {
        return task.done?.contains(where: { $0.completedFor == selectedDate }) ?? false
    }
    
    func checkMarkTapped(task: MainModel) -> MainModel {
        let model = task
        model.value.done = updateExistingTaskCompletion(task: model.value)
        
        return model
    }
    
    /// Update complete record for task
    private func updateExistingTaskCompletion(task: TaskModel) -> [CompleteRecord] {
        guard let existingRecords = task.done else {
            return [createNewTaskCompletion(task: task)]
        }
        
        if let existingIndex = existingRecords.firstIndex(where: { $0.completedFor == selectedDate }) {
            var updatedRecords = existingRecords
            updatedRecords.remove(at: existingIndex)
            return updatedRecords
        } else {
            var updatedRecords = existingRecords
            updatedRecords.append(createNewTaskCompletion(task: task))
            return updatedRecords
        }
    }
    
    /// Create new complition record for task
    private func createNewTaskCompletion(task: TaskModel) -> CompleteRecord {
        CompleteRecord(completedFor: selectedDate,timeMark: nowDate)
    }
    
    //MARK: - Delete functions
    func deleteTask(task: MainModel, deleteCompletely: Bool = false) -> MainModel {
        guard task.value.markAsDeleted == false else {
            return task
        }
        
        let model = task
        
        if deleteCompletely == true {
            model.value.markAsDeleted = true
        } else {
            model.value.deleted = updateExistingTaskDeleted(task: model.value)
        }
        
        return model
    }
    
    /// Update delete record for task
    func updateExistingTaskDeleted(task: TaskModel,) -> [DeleteRecord] {
        var newDeletedRecords: [DeleteRecord] = []
        
        if let deletedRecord = task.deleted {
            newDeletedRecords = deletedRecord
            newDeletedRecords.append(DeleteRecord(deletedFor: selectedDate, timeMark: nowDate))
        } else {
            newDeletedRecords.append(DeleteRecord(deletedFor: selectedDate, timeMark: nowDate))
        }
        
        return newDeletedRecords
    }
}
