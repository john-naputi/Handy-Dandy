//
//  ActivityType.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/2/25.
//

enum ActivityType: String, Codable, CaseIterable {
    case general, shopping, dining, entertainment, travel, transportation, fitness, education, work, personal, hobbies, relationships, finance, other
    
    var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .shopping: return "Shopping"
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
}
