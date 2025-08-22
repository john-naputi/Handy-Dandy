//
//  DraftSingleTaskPlan.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import Foundation

struct DraftSingleTaskPlan: Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String?
    var dueAt: Date?
    var isDone: Bool
    
    init(id: UUID = .init(),
         title: String,
         notes: String? = nil,
         dueAt: Date? = nil,
         isDone: Bool = false) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueAt = dueAt
        self.isDone = isDone
    }
    
    init(from shadow: SingleTaskShadow) {
        self.id = shadow.id
        self.title = shadow.planTitle
        self.notes = shadow.notes
        self.dueAt = shadow.dueAt
        self.isDone = shadow.isDone
    }
}
