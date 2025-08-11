//
//  Experience.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/3/25.
//

import SwiftData
import SwiftUI
import Foundation

enum ExperienceType: String, Codable, CaseIterable {
    case flow
    case emergency
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .flow: return "Flow"
        case .emergency: return "Emergency"
        }
    }
}

extension ExperienceType {
    var emoji: String {
        switch self {
        case .flow: return "🌀"
        case .emergency: return "🚨"
        }
    }
}

enum RecurrenceRule: String, Codable, CaseIterable {
    case daily, weekly, monthly, yearly
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

@Model
class Experience: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var experienceDescription: String?
    var type: ExperienceType
    var startDate: Date
    var endDate: Date
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var budgetLimit: Double?
    var pinned: Bool
    var colorTag: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var plans: [Plan]
    
    @Relationship(deleteRule: .cascade)
    var tags: [ExperienceTag]
    
    init(id: UUID = UUID(),
         title: String = "",
         experienceDescription: String? = nil,
         type: ExperienceType = .flow,
         startDate: Date = .now,
         endDate: Date = .now,
         isRecurring: Bool = false,
         recurrenceRule: RecurrenceRule? = nil,
         budgetLimit: Double? = nil,
         pinned: Bool = false,
         colorTag: String? = nil,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         plans: [Plan] = [],
         tags: [ExperienceTag] = []
    ) {
        self.id = id
        self.title = title
        self.experienceDescription = experienceDescription
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.budgetLimit = budgetLimit
        self.pinned = pinned
        self.colorTag = colorTag
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.plans = []
        self.tags = []
        
        self.plans.append(contentsOf: plans)
        for plan in self.plans {
            plan.experience = self
        }
        
        for tag in tags {
            self.add(tag)
        }
    }
}

extension Experience {
    func getExperienceDate() -> String {
        if startDate == endDate {
            return self.formatDate(startDate)
        }
        
        if startDate != endDate {
            return "\(self.formatDate(startDate)) - \(self.formatDate(endDate))"
        }
        
        return ""
    }
    
    func getColor(for scheme: ColorScheme) -> Color {
        return scheme == .dark ? .white : .black
    }
    
    private func formatDate(_ date: Date?) -> String {
        return date?.formatted(date: .abbreviated, time: .omitted) ?? ""
    }
}

extension Experience: ContainerModel {
    typealias TModel = ExperienceTag
    
    func add(_ item: ExperienceTag) {
        guard !item.isSystem else { return }
        guard !tags.contains(where: { $0.name == item.name }) else { return }
        
        item.experience = self
        tags.append(item)
    }
    
    func remove(_ item: ExperienceTag) -> ExperienceTag? {
        guard let index = self.tags.firstIndex(where: { $0.id == item.id }) else {
            return nil
        }
        
        let tag = self.tags.remove(at: index)
        
        return tag
    }
}

extension Experience {
    func add(plan: Plan) {
        self.plans.append(plan)
        plan.experience = self
    }
}

extension Experience {
    var systemTag: ExperienceTag {
        ExperienceTag(name: type.displayName, isSystem: true, emoji: type.emoji)
    }
    
    var allTags: [ExperienceTag] {
        [systemTag] + tags.sorted { $0.name < $1.name }
    }
}
