//
//  Task.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var isComplete: Bool = false
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    @Relationship(deleteRule: .nullify, inverse: \Plan.checklists)
    var checklist: Checklist?
    
    init(id: UUID = UUID(), title: String = "", description: String = "", isComplete: Bool = false, plan: Plan? = nil, checklist: Checklist? = nil) {
        self.id = id
        self.title = title
        self.taskDescription = description
        self.isComplete = isComplete
        self.plan = plan
        self.checklist = checklist
    }
    
    convenience init(from task: Task) {
        self.init(
            id: task.id,
            title: task.title,
            description: task.taskDescription,
            isComplete: task.isComplete,
            plan: task.plan,
            checklist: task.checklist
        )
    }
    
    func copy(from target: Task) {
        self.title = target.title
        self.taskDescription = target.taskDescription
        self.isComplete = target.isComplete
        self.plan = target.plan
        self.checklist = target.checklist
    }
    
    static func emptyDraft() -> Task {
        var task = Task(plan: nil, checklist: nil)
        
        return task
    }
}
