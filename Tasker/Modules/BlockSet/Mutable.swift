//
//  Mutable.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/6/25.
//

import Foundation

//public typealias MainModel = Model<TaskModel>
//
//public func mockModel() -> MainModel {
//    MainModel.initial(TaskModel(id: UUID().uuidString, title: "New task", info: "", createDate: Date.now.timeIntervalSince1970))
//}

struct Commit: Codable {
    var parent: [String]
    var blob: String?
}

struct Parent {
    var commitId: String
    var blobId: String?
}

public class Mutable: Hashable {
    var parent: Parent?
    // internal:
    init(_ parent: Parent?) {
        self.parent = parent
    }
    // public:
    public static func initial() -> Mutable {
        Mutable(nil)
    }
    // Hashable:
    public static func == (lhs: Mutable, rhs: Mutable) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
