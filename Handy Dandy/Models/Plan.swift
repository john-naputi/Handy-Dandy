//
//  Event.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import Foundation
import SwiftData
import SwiftUI

enum PlanKind: String, Codable, CaseIterable, Identifiable {
    case singleTask // Exactly one task
    case taskList // Sequence of Tasks
    case checklist // Sequence of Checklists
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .singleTask: "Single Task"
        case .taskList: "Task List"
        case .checklist: "Checklist"
        }
    }
    
    var explanation: String {
        switch self {
        case .singleTask: return "A plan focused on a single task."
        case .taskList: return "A plan that contains one or more tasks."
        case .checklist: return "A plan that contains one or more checklists."
        }
    }
    
    var allowedPlanTypes: [PlanType] {
        switch self {
        case .singleTask:
            return [.general, .maintenance, .emergency, .workout]
        case .taskList:
            return [.general, .maintenance, .emergency, .workout]
        case .checklist:
            return [.shopping, .maintenance, .general]
        }
    }
    
    func allows(_ type: PlanType) -> Bool {
        allowedPlanTypes.contains(type)
    }
}

enum PlanType: String, Codable, CaseIterable, Identifiable{
    case general // Default
    case shopping // Only valid for checklists
    case maintenance // Only valid for tasks
    case emergency // Only valid for tasks
    case workout // Reserved for the future, but tasks only
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .general:
            return "General"
        case .shopping:
            return "Shopping"
        case .maintenance:
            return "Maintenance"
        case .emergency:
            return "Emergency"
        case .workout:
            return "Workout"
        }
    }
    
    var explanation: String {
        switch self {
        case .general: return "A flexible plan with no specific category."
        case .shopping: return "A checklist used for groceries or other purchases."
        case .maintenance: return "A task for regular upkeep or system care."
        case .emergency: return "A task reserved for urgent or time-sensitive actions."
        case .workout: return "A structured sequence of physical activities."
        }
    }
    
    var symbol: String {
        switch self {
        case .general:     return "doc"   // Default / general-purpose
        case .shopping:    return "cart"   // Groceries, purchases
        case .maintenance: return "wrench"   // Wrench = repair/upkeep
        case .emergency:   return "exclamationmark.triangle"   // High-urgency visual
        case .workout:     return "figure.strengthtraining.traditional"   // Structured exercise
        }
    }
    
    var tintColor: some ShapeStyle {
        switch self {
        case .general: return .gray
        case .shopping: return .blue
        case .maintenance: return .orange
        case .emergency: return .red
        case .workout: return .green
        }
    }
}

@Model
class Plan {
    @Attribute(.unique) var id: UUID
    var title: String
    var planDescription: String
    var planDate: Date
    var kind: PlanKind
    var type: PlanType
    
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
        kind: PlanKind = .checklist,
        type: PlanType = .shopping,
        checklist: [Checklist] = [],
        tasks: [ChecklistTask] = [],
        experience: Experience = Experience()
    ) {
        self.id = UUID()
        self.title = String(title.prefix(30))
        self.planDescription = String(description.prefix(30))
        self.planDate = planDate
        self.kind = kind
        self.type = type
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
