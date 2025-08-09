//
//  ExperienceDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct ExperienceDetailDescriptor: View {
    let experience: Experience
    
    var body: some View {
        NavigationStack {
            List {
                Section("Plans") {
                    PlansListDescriptor(plans: experience.plans)
                }
                .font(.headline)
            }
        }
    }
}

#Preview {
    let experience = Experience(
        title: "Norway Ski Trip",
        type: .flow,
        plans: [], tags: [
            ExperienceTag(name: "Norway"),
            ExperienceTag(name: "Skiing")
        ]
    )
    ExperienceDetailDescriptor(experience: experience)
}
