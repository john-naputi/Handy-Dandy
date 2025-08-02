//
//  TaskItem.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import Foundation
import SwiftData

@Model
class Checklist {
    @Attribute(.unique) var id: UUID
    var title: String
    var checklistDescription: String
    var isComplete: Bool
    var activityType: ActivityType
    
    @Relationship
    var shoppingChecklist: ShoppingChecklist?
    
    @Relationship(deleteRule: .cascade, inverse: \ChecklistTask.checklist)
    var tasks: [ChecklistTask]
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        checklistDescription: String = "",
        isComplete: Bool = false,
        activityType: ActivityType = .general,
        shoppingChecklist: ShoppingChecklist? = nil,
        tasks: [ChecklistTask] = [],
        plan: Plan? = nil
    ) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.activityType = activityType
        self.shoppingChecklist = shoppingChecklist
        self.checklistDescription = checklistDescription
        self.plan = plan
        self.tasks = []
    }
}

extension Checklist {
    var sortedTasks: [ChecklistTask] {
        tasks.sorted {
            if $0.isComplete == $1.isComplete {
                return $0.title < $1.title
            }
            
            return !$0.isComplete && $1.isComplete
        }
    }
}

extension Checklist: TaskContainer {
    func name() -> String {
        return self.title
    }
    
    func description() -> String {
        return self.checklistDescription
    }
    
    func addTask(_ task: ChecklistTask) {
        tasks.append(task)
    }
    
    func removeTask(_ task: ChecklistTask) {
        tasks.removeAll(where: { $0.id == task.id })
    }
}
