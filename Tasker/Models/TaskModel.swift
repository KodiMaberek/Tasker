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
    var previousUniqueID: String?
    
    var title = "New Task"
    var info = ""
    var audio: URL?
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
    MainModel.initial(TaskModel(id: UUID().uuidString, title: "", info: "", createDate: Date.now.timeIntervalSince1970))
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
