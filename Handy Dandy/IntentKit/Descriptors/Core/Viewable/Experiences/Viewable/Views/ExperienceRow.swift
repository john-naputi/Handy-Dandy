//
//  ExperienceRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/4/25.
//

import SwiftUI
import Foundation

struct ExperienceRow: View {
    var experience: Experience
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(experience.title)
                .font(.headline)
            Text("Date: \(experience.getExperienceDate())")
            Text("Number of plans: \(experience.plans.count)")
                .foregroundStyle(.primary)
            
            let visibleTags: [ExperienceTag] = [experience.systemTag] + experience.tags.sorted(by: tagSort)
            let rows = chunked(visibleTags, into: 3)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 8) {
                        ForEach(rows[rowIndex], id: \.id) { tag in
                            TagPill(tag: tag)
                        }
                    }
                }
            }
            
            if let description = experience.experienceDescription, !description.isEmpty {
                Text(experience.experienceDescription!)
                    .font(.body)
                    .padding(.top, 6)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    private func tagSort(_ lhs: ExperienceTag, _ rhs: ExperienceTag) -> Bool {
        switch (lhs.isSystem, rhs.isSystem) {
        case (true, false): return true
        case (false, true): return false
        default: return lhs.name < rhs.name
        }
    }
    
    private func chunked<T>(_ array: [T], into size: Int) -> [[T]] {
        stride(from: 0, to: array.count, by: size).map {
            Array(array[$0..<min($0 + size, array.count)])
        }
    }

}

#Preview {
    let experience = Experience(
        title: "Las Vegas Trip",
        experienceDescription: "Family trip to Las Vegas, Nevada",
        type: .flow,
        startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3)) ?? .now,
        endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10)) ?? .now,
        tags: [
            ExperienceTag(name: "Winter", isSystem: true, emoji: "❄️"),
            ExperienceTag(name: "Skiing", emoji: "⛷️"),
            ExperienceTag(name: "Austria", emoji: "🇦🇹")
        ]
    )
    ExperienceRow(experience: experience)
}
