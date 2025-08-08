//
//  Tag.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/4/25.
//

import SwiftData
import SwiftUI

@Model
class ExperienceTag {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    var isSystem: Bool
    var emoji: String?
    
    @Relationship()
    var experience: Experience?
    
    init(id: UUID = UUID(), name: String = "", isSystem: Bool = false, emoji: String? = nil, experience: Experience? = nil) {
        self.id = id
        self.name = name
        self.isSystem = isSystem
        self.emoji = emoji
        self.experience = experience
    }
}

extension ExperienceTag {
    
    var displayEmoji: String? {
        if isSystem {
            return SystemTagLibrary[name]?.emoji
        } else {
            return emoji
        }
    }
    
    var isSeason: Bool {
        ["Winter", "Spring", "Summer", "Autumn"].contains(name)
    }
    
    func getColor(for colorScheme: ColorScheme) -> Color {
        if isSystem, let systemStyle = SystemTagLibrary[name.capitalized] {
            return (colorScheme == .dark) ? systemStyle.darkColor : systemStyle.lightColor
        } else {
            return Color(red: 0.40, green: 0.40, blue: 0.45)
        }
    }
}

extension ExperienceTag {
    var normalizedKey: String {
        name.normalizedName
    }
}
