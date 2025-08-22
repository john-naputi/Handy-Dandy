//
//  SingleTaskShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import Foundation

typealias SingleTaskShadowFactory = (_ plan: Plan, _ task: SingleTask) -> SingleTaskShadow.Derived

enum SingleTaskShadowRegistry {
    static var make: SingleTaskShadowFactory = { plan, task in
        task.payload.fold { _ in
                .init(icon: "checkmark.circle", subtitle: task.notes)
        }
        
        // Later, when there are more flavors, switch on task.flavor or payload.fold
    }
}

struct SingleTaskShadow: Equatable, Identifiable {
    struct Derived: Equatable {
        var icon: String?
        var subtitle: String?
        static let empty: SingleTaskShadow.Derived = .init(icon: nil, subtitle: nil)
    }
    
    let id: UUID
    let planTitle: String
    let notes: String?
    let isDone: Bool
    let dueAt: Date?
    
    let icon: String?
    let subtitle: String?
    
    var progress: Double {
        isDone ? 1 : 0
    }
    
    var statusText: String {
        isDone ? "Completed" : "Not completed"
    }
    
    init(plan: Plan, task: SingleTask, derived: Derived = .empty) {
        self.id = task.uid
        self.planTitle = plan.title
        self.isDone = task.isDone
        self.notes = task.notes
        self.dueAt = task.dueAt
        self.icon = derived.icon
        self.subtitle = derived.subtitle
    }
    
    init(id: UUID = .init(),
         title: String,
         notes: String? = nil,
         isDone: Bool = false,
         dueAt: Date? = nil) {
        self.init(id: id, title: title, notes: notes, isDone: isDone, dueAt: dueAt, icon: nil, subtitle: nil)
    }
    
    init (id: UUID = UUID(),
          title: String,
          notes: String? = nil,
          isDone: Bool = false,
          dueAt: Date? = nil,
          icon: String?,
          subtitle: String?) {
        self.id = id
        self.planTitle = title
        self.notes = notes
        self.isDone = isDone
        self.dueAt = dueAt
        self.icon = icon
        self.subtitle = subtitle
    }
    
    func toggled() -> SingleTaskShadow {
        .init(id: id, title: planTitle, notes: notes, isDone: !isDone, dueAt: dueAt, icon: icon, subtitle: subtitle)
    }
    
    func rename(to newTitle: String) -> SingleTaskShadow {
        .init(id: id, title: newTitle, notes: notes, isDone: isDone, dueAt: dueAt, icon: icon, subtitle: subtitle)
    }
    
    func withNotes(_ newNotes: String?) -> SingleTaskShadow {
        .init(id: id, title: planTitle, notes: newNotes, isDone: isDone, dueAt: dueAt, icon: icon, subtitle: subtitle)
    }
    
    func withDueAt(_ newDue: Date?) -> SingleTaskShadow {
        .init(id: id, title: planTitle, notes: notes, isDone: isDone, dueAt: newDue, icon: icon, subtitle: subtitle)
    }
}
