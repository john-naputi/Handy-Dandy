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
    
    @Relationship(deleteRule: .cascade, inverse: \Task.checklist)
    var tasks: [Task]
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        checklistDescription: String = "",
        isComplete: Bool = false,
        tasks: [Task] = [],
        plan: Plan? = nil
    ) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.checklistDescription = checklistDescription
        self.plan = plan
        self.tasks = []
    }
}

extension Checklist {
    var sortedTasks: [Task] {
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
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func removeTask(_ task: Task) {
        tasks.removeAll(where: { $0.id == task.id })
    }
}
