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
class TaskModel: Identifiable {
    var uniqueID = UUID().uuidString
    
    var title = "New Task"
    var info = ""
    var audio: URL?
    
    var createDate: Double = Date.now.timeIntervalSince1970
    var endDate: Double?
    var notificationDate: Double?
    var seconNotificationDate: Double?
    var voiceMode = true
    
    var repeatTask = RepeatTask.never
    
    @Relationship(inverse: \CompleteRecord.self) var done: CompleteRecord?
    @Relationship(inverse: \DeleteRecord.self) var deleted: DeleteRecord?
    
    var taskColor = TaskColor.yellow
    
    init(title: String, info: String, createDate: Double) {
        self.title = title
        self.info = info
        self.createDate = createDate
    }
}

@Model
class CompleteRecord {
    var done: Bool
    var completedFor: [Double]?
    var timeMark: [Double]?
    
    init(done: Bool = false, completedFor: [Double]? = nil, timeMark: [Double]? = nil) {
        self.done = done
        self.completedFor = completedFor
        self.timeMark = timeMark
    }
}

@Model
class DeleteRecord {
    var deleted: Bool
    var deletedFor: [Double]?
    var timeMark: [Double]?
    
    init(deleted: Bool = false, deletedFor: [Double]? = nil, timeMark: [Double]? = nil) {
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
