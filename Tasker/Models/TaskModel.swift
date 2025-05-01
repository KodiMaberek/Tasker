//
//  TaskModel.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/10/25.
//

import Foundation
import SwiftData
import SwiftUICore

@Model
class TaskModel: Identifiable, Equatable {
    var uniqueID = UUID().uuidString
    var previousUniqueID: String?
    
    var title = "New Task"
    var info = ""
    var audio: URL?
    
    var createDate: Double = Date.now.timeIntervalSince1970
    var endDate: Double?
    var notificationDate: Double = 00
    var secondNotificationDate: Double?
    var voiceMode = true
    
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
    
    @Relationship(deleteRule: .cascade) var done: [CompleteRecord]?
    @Relationship(deleteRule: .cascade) var deleted: DeleteRecord?
    
    var taskColor = TaskColor.yellow
    
    init(title: String, info: String, createDate: Double) {
        self.title = title
        self.info = info
        self.createDate = createDate
    }
}

@Model
class CompleteRecord {
    @Relationship var task: TaskModel?
    
    var done: Bool = false
    var completedFor: Double? = nil
    var timeMark: Double? = nil
    
    init(task: TaskModel, done: Bool = false, completedFor: Double, timeMark: Double? = nil) {
        self.task = task
        self.done = done
        self.completedFor = completedFor
        self.timeMark = timeMark
    }
}

@Model
class DeleteRecord {
    @Relationship var task: TaskModel?
    
    var deleted: Bool = false
    var deletedFor: [Double]? = nil
    var timeMark: [Double]? = nil
    
    init(task: TaskModel, deleted: Bool = false, deletedFor: [Double]? = nil, timeMark: [Double]? = nil) {
        self.task = task
        self.deleted = deleted
        self.deletedFor = deletedFor
        self.timeMark = timeMark
    }
}

func mockModel() -> TaskModel {
    TaskModel(title: "", info: "", createDate: Date.now.timeIntervalSince1970)
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



