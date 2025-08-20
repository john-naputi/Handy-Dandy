//
//  PlanSupport.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/11/25.
//

import Foundation
import SwiftData
import SwiftUI

enum PlanKind: String, Codable, CaseIterable, Identifiable {
    case singleTask // Exactly one task
    case taskList // Sequence of Tasks
    case checklist // Sequence of Checklists
    case shoppingList
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .singleTask: "Single Task"
        case .taskList: "Task List"
        case .checklist: "Checklist"
        case .shoppingList: "Shopping List"
        }
    }
    
    var explanation: String {
        switch self {
        case .singleTask: return "Exactly one task. Great for a single workout or errand."
        case .taskList: return "One or more tasks. Optionally ordered or timed."
        case .checklist: return "One or more checklists (e.g., a Shopping List)."
        case .shoppingList: return "A list of items to buy from a store."
        }
    }
    
    var allowedPlanTypes: [PlanType] {
        switch self {
        case .singleTask:
            return [.general, .maintenance, .emergency, .fitness]
        case .taskList:
            return [.general, .maintenance, .emergency, .fitness]
        case .checklist:
            return [.shopping, .general]
        case .shoppingList:
            return [.general, .shopping]
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
    case dining
    case entertainment
    case travel
    case transportation
    case fitness
    case education
    case work
    case personal, hobbies
    case relationships
    case finance
    case other
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .shopping: return "Shopping"
        case .maintenance: return "Maintenance"
        case .emergency: return "Emergency"
        case .dining: return "Dining"
        case .entertainment: return "Entertainment"
        case .travel: return "Travel"
        case .transportation: return "Transportation"
        case .fitness: return "Fitness"
        case .education: return "Education"
        case .work: return "Work"
        case .personal: return "Personal"
        case .hobbies: return "Hobbies"
        case .relationships: return "Relationships"
        case .finance: return "Finance"
        case .other: return "Other"
        }
    }
    
    var explanation: String {
        switch self {
        case .general: return "Flexible plan with no specific category."
        case .shopping: return "Checklist for groceries or other purchases"
        case .maintenance: return "Upkeep, repairs, or recurring system care."
        case .emergency: return "Urgent, time-sensitive actions."
        case .dining: return "Meals, reservations, or cooking plans."
        case .entertainment: return "Leisure, shows, games, or social time."
        case .travel: return "Trips, flights, lodging, and itinerary steps."
        case .transportation: return "Rides, commutes, and transit logistics."
        case .fitness: return "Workouts, training sessions, or lessons."
        case .education: return "Classes, study sessions, or lessons."
        case .work: return "Professional tasks and deliverables."
        case .personal: return "Self-care, errands, and personal upkeep."
        case .hobbies: return "Creative projects and pastimes."
        case .relationships: return "Family, friends, and community touchpoints."
        case .finance: return "Budgeting, bills, and money management."
        case .other: return "Doesn't fit elsewhere - experiment freely."
        }
    }
    
    var symbol: String {
        switch self {
        case .general:     return "doc"   // Default / general-purpose
        case .shopping:    return "cart"   // Groceries, purchases
        case .maintenance: return "wrench"   // Wrench = repair/upkeep
        case .emergency:   return "exclamationmark.triangle"   // High-urgency visual
        case .dining: return "fork.knife"
        case .entertainment: return "theatermasks"
        case .travel: return "airplane"
        case .transportation: return "car" // Alt: tram
        case .fitness: return "figure.run" // Alt: "figure.strengthtraining.traditional"
        case .education: return "graduationcap" // Alt: book.closed
        case .work: return "briefcase" // Alt: building.2
        case .personal: return "person.crop.circle"
        case .hobbies: return "paintpalette"
        case .relationships: return "person.2"
        case .finance: return "dollarsign.circle"
        case .other: return "ellipsis.circle"
        }
    }
    
    var tintColor: some ShapeStyle {
        switch self {
        case .general: return .gray
        case .shopping: return .blue
        case .maintenance: return .orange
        case .emergency: return .red
        case .dining: return .yellow
        case .entertainment: return .purple
        case .travel: return .teal
        case .transportation: return .cyan
        case .fitness: return .mint // Alt: .green
        case .education: return .indigo
        case .work: return .brown
        case .personal: return .pink
        case .hobbies: return .purple.opacity(0.85)
        case .relationships: return .pink.opacity(0.85)
        case .finance: return .green
        case .other: return .gray
        }
    }
}

enum PlanCadence: String, Identifiable, Codable, CaseIterable {
    case freeform, sequence, timed, locationAware, emergency
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .freeform:
            return "Freeform"
        case .sequence:
            return "Sequence"
        case .timed:
            return "Timed"
        case .locationAware:
            return "Location-Aware"
        case .emergency:
            return "Emergency"
        }
    }
    
    var explanation: String {
        switch self {
        case .freeform:
            return "Do steps in any order, at your own pace."
        case .sequence:
            return "Do steps in an order. The next step unlocks as you progress."
        case .timed:
            return "Steps are scheduled by time or duration."
        case .locationAware:
            return "Steps surface when you arrive, leave, or dwell at a place."
        case .emergency:
            return "Crisis flow with clear priorities."
        }
    }
}

enum Trigger: String, Hashable, Codable {
    case onPreviousComplete, onTime, onLocationEnter
}

struct PlanPolicy {
    // Structure permissions
    let allowTasks: Bool
    let allowChecklists: Bool
    let requireSingleTask: Bool
    
    // Checklist shape
    let defaultChecklistKind: ChecklistKind
    let allowedChecklistKinds: [ChecklistKind]
    
    // Behavior
    let allowedCadences: [PlanCadence]
    let defaultCadence: PlanCadence
    let triggers: Set<Trigger>
    
    // Friendly hints
    let creationHint: String
}

extension PlanPolicy {
    static func forContext(type: PlanType, kind: PlanKind, cadence: PlanCadence) -> PlanPolicy {
        switch (type, kind) {
        // Shopping
        case (.shopping, .checklist):
            return .init(
                allowTasks: false,
                allowChecklists: true,
                requireSingleTask: false,
                defaultChecklistKind: .shoppingList,
                allowedChecklistKinds: [.shoppingList, .general],
                allowedCadences: [.freeform, .locationAware],
                defaultCadence: .freeform,
                triggers: cadence == .locationAware ? [.onLocationEnter] : [],
                creationHint: "Start a Shopping List. Add a Place to enable location prompts."
            )

        // Fitness
        case (.fitness, .singleTask):
            return .init(
                allowTasks: true, allowChecklists: false, requireSingleTask: true,
                defaultChecklistKind: .general, allowedChecklistKinds: [.general],
                allowedCadences: [.freeform], defaultCadence: .freeform,
                triggers: [], creationHint: "Describe the session (e.g., 'Bike 100 miles')."
            )
        case (.fitness, .taskList):
            return .init(
                allowTasks: true, allowChecklists: false, requireSingleTask: false,
                defaultChecklistKind: .general, allowedChecklistKinds: [.general],
                allowedCadences: [.freeform, .sequence, .timed], defaultCadence: .sequence,
                triggers: cadence == .sequence ? [.onPreviousComplete] :
                          cadence == .timed    ? [.onTime] : [],
                creationHint: "Add steps; choose Sequence for guided workouts."
            )

        // Transportation: single leg or multi-leg itineraries
        case (.transportation, .singleTask), (.transportation, .taskList):
            return .init(
                allowTasks: true, allowChecklists: false,
                requireSingleTask: kind == .singleTask,
                defaultChecklistKind: .general, allowedChecklistKinds: [],
                allowedCadences: [.freeform, .timed, .locationAware], defaultCadence: .locationAware,
                triggers: [.onLocationEnter],
                creationHint: "Set a destination. Auto-complete on arrival."
            )

        // Travel: packing/check-in steps (often checklists)
        case (.travel, .checklist):
            return .init(
                allowTasks: false, allowChecklists: true, requireSingleTask: false,
                defaultChecklistKind: .general, allowedChecklistKinds: [.general],
                allowedCadences: [.freeform], defaultCadence: .freeform,
                triggers: [],
                creationHint: "Build a packing or pre-flight checklist."
            )
        case (.travel, .taskList):
            return .init(
                allowTasks: true, allowChecklists: false, requireSingleTask: false,
                defaultChecklistKind: .general, allowedChecklistKinds: [],
                allowedCadences: [.freeform, .timed, .locationAware], defaultCadence: .timed,
                triggers: cadence == .locationAware ? [.onLocationEnter] :
                          cadence == .timed         ? [.onTime] : [],
                creationHint: "Add itinerary steps; schedule times or use location prompts."
            )

        // Dining: reservation (timed) or arrival (location)
        case (.dining, .singleTask), (.dining, .taskList):
            return .init(
                allowTasks: true, allowChecklists: false,
                requireSingleTask: kind == .singleTask,
                defaultChecklistKind: .general, allowedChecklistKinds: [],
                allowedCadences: [.freeform, .timed, .locationAware], defaultCadence: .timed,
                triggers: cadence == .locationAware ? [.onLocationEnter] :
                          cadence == .timed         ? [.onTime] : [],
                creationHint: "Add reservation time and place; we’ll prompt on time or arrival."
            )

        // Maintenance & Emergency
        case (.maintenance, .taskList), (.emergency, .taskList):
            return .init(
                allowTasks: true, allowChecklists: false, requireSingleTask: false,
                defaultChecklistKind: .general, allowedChecklistKinds: [.general],
                allowedCadences: [.freeform, .sequence, .timed],
                defaultCadence: (type == .emergency) ? .sequence : .freeform,
                triggers: (type == .emergency) ? [.onPreviousComplete] : [],
                creationHint: type == .emergency ? "Order steps for clear priorities." : "Add steps and optional schedule."
            )

        // Generic checklists (non-shopping)
        case (.general, .checklist):
            return .init(
                allowTasks: false, allowChecklists: true, requireSingleTask: false,
                defaultChecklistKind: .general, allowedChecklistKinds: [.general],
                allowedCadences: [.freeform], defaultCadence: .freeform,
                triggers: [], creationHint: "Create a checklist for anything."
            )

        // Default fallback
        default:
            let tasksOK = kind != .checklist
            let listsOK = kind == .checklist
            return .init(
                allowTasks: tasksOK,
                allowChecklists: listsOK,
                requireSingleTask: kind == .singleTask,
                defaultChecklistKind: .general,
                allowedChecklistKinds: listsOK ? [.general] : [],
                allowedCadences: kind == .taskList ? [.freeform, .sequence, .timed] : [.freeform],
                defaultCadence: .freeform,
                triggers: [],
                creationHint: "Set up your plan."
            )
        }
    }
}
