//
//  Event.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import Foundation
import SwiftData

@Model
class Plan {
    @Attribute(.unique) var id: UUID
    var title: String
    var planDescription: String
    var planDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Checklist.plan)
    var checklists: [Checklist]
    
    @Relationship(deleteRule: .cascade, inverse: \ChecklistTask.plan)
    var tasks: [ChecklistTask]
    
    @Relationship()
    var experience: Experience
    
    init(
        title: String = "",
        description: String = "",
        planDate: Date = .now,
        checklist: [Checklist] = [],
        tasks: [ChecklistTask] = [],
        experience: Experience = Experience()
    ) {
        self.id = UUID()
        self.title = String(title.prefix(30))
        self.planDescription = String(description.prefix(30))
        self.planDate = planDate
        self.checklists = []
        self.tasks = []
        self.experience = experience
        
        self.checklists.append(contentsOf: checklists)
        for checklist in self.checklists {
            checklist.plan = self
        }
        
        self.tasks.append(contentsOf: tasks)
        for task in self.tasks {
            task.plan = self
        }
    }
}

extension Plan: TaskContainer {
    func name() -> String {
        return self.title
    }
    
    func description() -> String {
        return self.planDescription
    }
    
    func addTask(_ task: ChecklistTask) {
        self.tasks.append(task)
    }
    
    func removeTask(_ task: ChecklistTask) {
        self.tasks.removeAll(where: { $0.id == task.id })
    }
}
