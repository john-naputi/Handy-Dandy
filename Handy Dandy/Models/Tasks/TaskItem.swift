//
//  TaskItem.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import SwiftData
import Foundation

@Model
final class TaskItem {
    @Attribute(.unique) var taskItemId: UUID
    var text: String
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date
    var sortIndex: Int
    
    init(id: UUID = UUID(),
         text: String = "",
         isDone: Bool = false,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         sortIndex: Int = 0) {
        self.taskItemId = id
        self.text = text
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortIndex = sortIndex
    }
    
    #if DEBUG
    func debugString() -> String {
        "TaskItem(taskItemId=\(taskItemId), text=\(text), isDone=\(isDone), createdAt=\(createdAt), updatedAt=\(updatedAt), sortIndex=\(sortIndex))"
    }
    #endif
}
