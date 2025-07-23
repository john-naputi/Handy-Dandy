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
    var planDescription: String?
    var planDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Checklist.plan)
    var checklists: [Checklist]
    
    @Relationship(deleteRule: .cascade, inverse: \Task.plan)
    var tasks: [Task]
    
    init(title: String, description: String? = nil, planDate: Date = .now) {
        self.id = UUID()
        self.title = String(title.prefix(30))
        self.planDescription = description.map { String($0.prefix(150)) }
        self.planDate = planDate
        self.checklists = []
        self.tasks = []
    }
}
