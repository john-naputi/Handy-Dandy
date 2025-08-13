//
//  Event.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Plan {
    @Attribute(.unique) var id: UUID
    var title: String
    var planDescription: String
    var planDate: Date
    var kind: PlanKind
    var type: PlanType
    var cadence: PlanCadence
    
    @Relationship(deleteRule: .cascade, inverse: \Checklist.plan)
    var checklists: [Checklist]
    
    @Relationship(deleteRule: .cascade, inverse: \ChecklistTask.plan)
    var tasks: [ChecklistTask]
    
    @Relationship(deleteRule: .nullify)
    var experience: Experience?
    
    init(
        title: String = "",
        description: String = "",
        planDate: Date = .now,
        kind: PlanKind = .checklist,
        type: PlanType = .shopping,
        cadence: PlanCadence = .freeform,
        checklists: [Checklist] = [],
        tasks: [ChecklistTask] = [],
        experience: Experience? = nil
    ) {
        self.id = UUID()
        self.title = String(title.prefix(30))
        self.planDescription = String(description.prefix(30))
        self.planDate = planDate
        self.kind = kind
        self.type = type
        self.cadence = cadence
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
        task.plan = self
    }
    
    func removeTask(_ task: ChecklistTask) {
        self.tasks.removeAll(where: { $0.id == task.id })
        task.plan = nil
    }
}

extension Plan {
    func add(checklist: Checklist) {
        checklists.append(checklist)
        checklist.plan = self
    }
    
    func remove(checklist: Checklist) {
        guard let index = checklists.firstIndex(where: { $0.id == checklist.id }) else {
            return
        }
        
        self.checklists.remove(at: index)
        checklist.plan = nil
    }
    
    func update(_ id: UUID, with other: Checklist) {
        guard let index = checklists.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let target = checklists[index]
        target.title = other.title
        target.checklistDescription = other.checklistDescription
        target.kind = other.kind
        
        target.tasks.removeAll()
        for task in other.tasks {
            target.tasks.append(task)
            task.checklist = target
        }
        
        target.shoppingList = other.shoppingList
    }
}

extension Plan {
    var policy: PlanPolicy {
        .forContext(type: type, kind: kind, cadence: cadence)
    }
    
    func isValid() -> Bool {
        guard kind.allows(type) else {
            return false
        }
        
        if policy.requireSingleTask, tasks.count > 1 {
            return false
        }
        
        if policy.allowChecklists, kind == .checklist, !tasks.isEmpty {
            return false
        }
        
        if policy.allowTasks, kind != .checklist, !checklists.isEmpty {
            return false
        }
        
        return true
    }
}
