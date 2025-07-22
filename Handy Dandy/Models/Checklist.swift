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
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    @Relationship(deleteRule: .cascade, inverse: \Task.checklist)
    var tasks: [Task]
    
    init(title: String, plan: Plan?) {
        self.id = UUID()
        self.title = title
        self.plan = plan
        self.tasks = []
    }
}
