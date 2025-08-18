//
//  TaskList.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation
import SwiftData

@Model
final class TaskList {
    @Attribute(.unique) var taskListId: UUID = UUID()
    var title: String
    var notes: String?
    var tasks: [TaskItem]
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Plan.taskLists)
    var plan: Plan?
    
    init(title: String = "",
         notes: String? = nil,
         tasks: [TaskItem] = [],
         createdAt: Date = .now,
         updatedAt: Date = .now,
         plan: Plan? = nil) {
        self.title = title
        self.notes = notes
        self.tasks = tasks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.plan = plan
    }
}
