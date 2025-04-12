//
//  TaskModel.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 4/10/25.
//

import Foundation
import SwiftData

@Model
class TaskModel {
    var title: String = "New Task"
    var info: String = ""
    
    var createDate: Double = Date.now.timeIntervalSince1970
    var endDate: Double?
    var notificationDate: Double?
    var seconNotificationDate: Double?
    
    @Attribute(.externalStorage) var audio: Data?
    
    var done: [CompleteRecord]?
    var deleted: [DeleteRecord]?
    
    init(title: String, info: String, createDate: Double, done: Bool) {
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
    
    init(done: Bool, completedFor: [Double]? = nil, timeMark: [Double]? = nil) {
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
    
    init(deleted: Bool, deletedFor: [Double]? = nil, timeMark: [Double]? = nil) {
        self.deleted = deleted
        self.deletedFor = deletedFor
        self.timeMark = timeMark
    }
}
