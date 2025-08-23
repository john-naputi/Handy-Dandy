//
//  TaskList.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation
import SwiftData

enum TaskListFlavor: String, Codable, CaseIterable {
    case checklist, shopping
    
    var name: String {
        switch self {
        case .checklist: "Checklist"
        case .shopping: "Shopping List"
        }
    }
}

@Model
final class TaskList {
    @Attribute(.unique) var taskListId: UUID = UUID()
    var title: String
    var notes: String?
    var flavor: TaskListFlavor
    var createdAt: Date
    var updatedAt: Date
    
    // Inline v1 shopping metadata
    var curencyCodeRaw: String?
    var plannedBudget: Decimal?
    var manualActualTotal: Decimal?
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.list)
    var tasks: [TaskItem]
    
    @Relationship(deleteRule: .cascade, inverse: \Plan.taskLists)
    var plan: Plan?
    
    init(title: String = "",
         notes: String? = nil,
         flavor: TaskListFlavor = .checklist,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         currencyCode: CurrencyCode? = nil,
         plannedBudget: Decimal? = nil,
         manualActualTotal: Decimal? = nil,
         tasks: [TaskItem] = [],
         plan: Plan? = nil) {
        self.title = title
        self.notes = notes
        self.flavor = flavor
        self.curencyCodeRaw = currencyCode?.rawValue
        self.plannedBudget = plannedBudget
        self.manualActualTotal = manualActualTotal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tasks = tasks
        self.plan = plan
    }
}

// Shopping List helpers
extension TaskList {
    var currencyCode: CurrencyCode? {
        let currencyCode = self.curencyCodeRaw ?? Locale.current.currency?.identifier ?? "USD"
        
        return CurrencyCode(rawValue: currencyCode)
    }
    
    var estimateTotal: Decimal {
        tasks.compactMap { $0.expectedPrice }.reduce(.zero, +)
    }
    
    var actualSubtotal: Decimal {
        tasks.compactMap { $0.actualPrice }.reduce(.zero, +)
    }
    
    var actualTotalDisplay: Decimal? {
        manualActualTotal ?? (actualSubtotal == .zero ? nil : actualSubtotal)
    }
    
    var budgetDelta: Decimal? {
        guard let budget = plannedBudget else { return nil }
        return (actualTotalDisplay ?? estimateTotal) - budget
    }
}
