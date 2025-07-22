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
    var taskDescription: String?
    var isComplete: Bool = false
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    @Relationship(deleteRule: .nullify, inverse: \Plan.checklists)
    var checklist: Checklist?
    
    init(title: String, description: String?, isComplete: Bool = false, plan: Plan?, checklist: Checklist?) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.isComplete = isComplete
        self.plan = plan
        self.checklist = checklist
    }
}
