//
//  MainModel.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/10/25.
//

import Foundation
import SwiftData
import SwiftUICore

///Model for CAS
typealias MainModel = Model<TaskModel>

struct TaskModel: Identifiable, Codable {
    var id: String
    
    var title = ""
    var info = ""
    var audio: String? = nil
    var repeatModel: Bool? = false
    
    var createDate = Date.now.timeIntervalSince1970
    var endDate: Double?
    var notificationDate: Double = 00
    var secondNotificationDate: Double?
    var voiceMode = true
    
    var markAsDeleted = false
    
    var repeatTask = RepeatTask.never
    var dayOfWeek: [DayOfWeek] = [
        DayOfWeek(name: "Sun", value: false),
        DayOfWeek(name: "Mon", value: false),
        DayOfWeek(name: "Tue", value: false),
        DayOfWeek(name: "Wed", value: false),
        DayOfWeek(name: "Thu", value: false),
        DayOfWeek(name: "Fri", value: false),
        DayOfWeek(name: "Sat", value: false)
    ]
    
    var done: [CompleteRecord]?
    var deleted: [DeleteRecord]?
    
    var taskColor = TaskColor.yellow
}

struct CompleteRecord: Codable, Equatable {
    var completedFor: Double?
    var timeMark: Double?
}

struct DeleteRecord: Codable {
    var deletedFor: Double?
    var timeMark: Double?
}

func mockModel() -> MainModel {
    MainModel.initial(TaskModel(id: UUID().uuidString, title: "New task", info: "", createDate: Date.now.timeIntervalSince1970))
}

enum RepeatTask: CaseIterable, Codable, Identifiable {
    case never
    case daily
    case weekly
    case monthly
    case yearly
    case dayOfWeek
    
    var id: Self { self }
    
    var description: Text {
        switch self {
        case .never: return Text("Never")
        case .daily: return Text("Every day")
        case .weekly: return Text("Every week")
        case .monthly: return Text("Every month")
        case .yearly: return Text("Every year")
        case .dayOfWeek: return Text("Day of week")
        }
    }
}

struct DayOfWeek: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var value: Bool
}


extension TaskModel {
    //MARK: - Check for visible
    func isScheduledForDate(_ date: Double, calendar: Calendar = Calendar.current) -> Bool {
            let taskNotificationDate = self.notificationDate
            
            let dateAsDate = Date(timeIntervalSince1970: date)
            let taskNotificationDateAsDate = Date(timeIntervalSince1970: taskNotificationDate)
            
            guard dateAsDate >= calendar.startOfDay(for: taskNotificationDateAsDate) else {
                return false
            }
            
            if let endDate = self.endDate {
                let taskEndDate = Date(timeIntervalSince1970: endDate)
                guard dateAsDate <= taskEndDate else {
                    return false
                }
            }
            
            switch self.repeatTask {
            case .never:
                return taskNotificationDate >= date &&
                taskNotificationDate < date + 86400
                
            case .daily:
                return true
                
            case .weekly:
                let taskWeekday = calendar.component(.weekday, from: taskNotificationDateAsDate)
                let selectedWeekday = calendar.component(.weekday, from: dateAsDate)
                return taskWeekday == selectedWeekday
                
            case .monthly:
                let taskDay = calendar.component(.day, from: taskNotificationDateAsDate)
                let selectedDay = calendar.component(.day, from: dateAsDate)
                return taskDay == selectedDay
                
            case .yearly:
                let taskMonth = calendar.component(.month, from: taskNotificationDateAsDate)
                let taskDay = calendar.component(.day, from: taskNotificationDateAsDate)
                let selectedMonth = calendar.component(.month, from: dateAsDate)
                let selectedDay = calendar.component(.day, from: dateAsDate)
                return taskMonth == selectedMonth && taskDay == selectedDay
                
            case .dayOfWeek:
                let selectedWeekday = calendar.component(.weekday, from: dateAsDate)
                let dayIndex = selectedWeekday - 1
                
                guard dayIndex >= 0 && dayIndex < self.dayOfWeek.count else {
                    return false
                }
                
                return self.dayOfWeek[dayIndex].value
        }
    }
}
