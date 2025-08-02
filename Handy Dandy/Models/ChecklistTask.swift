//
//  Task.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import Foundation
import SwiftData

@Model
final class ChecklistTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var isComplete: Bool = false
    var activityType: ActivityType
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    @Relationship(deleteRule: .nullify, inverse: \Plan.checklists)
    var checklist: Checklist?
    
    init(id: UUID = UUID(), title: String = "", description: String = "", isComplete: Bool = false, activityType: ActivityType = .general, plan: Plan? = nil, checklist: Checklist? = nil) {
        self.id = id
        self.title = title
        self.taskDescription = description
        self.isComplete = isComplete
        self.activityType = activityType
        self.plan = plan
        self.checklist = checklist
    }
    
    convenience init(from task: ChecklistTask) {
        self.init(
            id: task.id,
            title: task.title,
            description: task.taskDescription,
            isComplete: task.isComplete,
            activityType: task.activityType,
            plan: task.plan,
            checklist: task.checklist
        )
    }
    
    func copy(from target: ChecklistTask) {
        self.title = target.title
        self.taskDescription = target.taskDescription
        self.isComplete = target.isComplete
        self.activityType = target.activityType
        self.plan = target.plan
        self.checklist = target.checklist
    }
    
    static func emptyDraft() -> ChecklistTask {
        let task = ChecklistTask(plan: nil, checklist: nil)
        
        return task
    }
}
