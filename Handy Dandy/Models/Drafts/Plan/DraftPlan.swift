//
//  DraftPlan.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct DraftPlan: Equatable {
    var title: String = ""
    var notes: String = ""
    var kind: PlanKind = .singleTask
    var type: PlanType = .general
    
    init(from plan: Plan) {
        self.title = plan.title
        self.notes = plan.planDescription
        self.kind = plan.kind
        self.type = plan.type
    }
    
    // Validation and sanitation
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    mutating func sanitize() {
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Materialize into a real Model
    func materialize() -> Plan {
        Plan(title: title, description: notes, kind: kind, type: type)
    }
}
