//
//  ViewableMultiExperienceDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/4/25.
//

import SwiftUI

struct ViewableMultiExperienceDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    var experiences: [Experience]
    
    @State private var showCreateExperienceSheet: Bool = false
    @State private var selectedExperience: Experience? = nil
    @State private var experienceToDelete: Experience? = nil
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if experiences.isEmpty {
                    Text("You haven't created any experiences yet.")
                        .foregroundStyle(.primary)
                        .padding()
                } else {
                    List {
                        ForEach(experiences) { experience in
                            NavigationLink {
                                ExperienceDetailDescriptor(experience: experience)
                            } label: {
                                ExperienceRow(experience: experience)
                                    .contextMenu {
                                        Button {
                                            self.selectedExperience = experience
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            self.experienceToDelete = experience
                                            showDeleteAlert.toggle()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Experiences")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateExperienceSheet.toggle()
                    } label: {
                        Label("Add Experience", systemImage: "plus")
                    }
                    .accessibilityIdentifier("AddExperienceButton")
                }
            }
            .sheet(isPresented: $showCreateExperienceSheet) {
                let experience = Experience()
                let intent = EditableExperienceIntent(
                    data: experience,
                    mode: .create,
                )
                let caller = EditableDescriptorCaller.experience(intent)
                
                EditableDescriptorView(caller: caller)
            }
            .sheet(item: $selectedExperience) { experience in
                let intent = EditableExperienceIntent(
                    data: experience,
                    mode: .update,
                    onCancel: {
                        selectedExperience = nil
                    },
                    onSave: { _ in
                        selectedExperience = nil
                    }
                )
                
                EditableExperienceDescriptor(intent: intent)
            }
            .alert(
                "Delete Experience?",
                isPresented: .init(
                    get: { experienceToDelete != nil },
                    set: { if !$0 { experienceToDelete = nil }}
                ),
                presenting: experienceToDelete,
                actions: { targetExperience in
                    Button("Delete", role: .destructive) {
                        modelContext.delete(targetExperience)
                        try? modelContext.save()
                    }
                    Button("Cancel", role: .cancel) {
                        experienceToDelete = nil
                    }
                },
                message: { targetExperience in
                    Text("Are you sure you want to delete the experience: \(targetExperience.title)?")
                }
            )
        }
    }
}

#Preview {
    let plans = [
        Plan(),
        Plan(),
        Plan()
    ]
    let experiences: [Experience] = [
        Experience(
            title: "Hemsedal Ski Trip",
            type: .flow,
            startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 10)) ?? .now,
            endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 28)) ?? .now,
            plans: plans,
            tags: [
                ExperienceTag(name: "Winter", isSystem: true, emoji: "❄️"),
                ExperienceTag(name: "Skiing", emoji: "⛷️"),
                ExperienceTag(name: "Norway", emoji: "🇳🇴")
            ]
        ),
        Experience(
            title: "Southwest Airlines Baggage Loss",
            type: .emergency,
            startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 10)) ?? .now,
            endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 28)) ?? .now,
            plans: plans,
            tags: [
                ExperienceTag(name: "Winter", isSystem: true, emoji: "❄️"),
                ExperienceTag(name: "Skiing", emoji: "⛷️"),
                ExperienceTag(name: "Norway", emoji: "🇳🇴")
            ]
        ),
        Experience(
            title: "Austria Ski Trip",
            experienceDescription: "Going to the Alps",
            type: .flow,
            startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3)) ?? .now,
            endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10)) ?? .now,
            tags: [
                ExperienceTag(name: "Winter", isSystem: true, emoji: "❄️"),
                ExperienceTag(name: "Skiing", emoji: "⛷️"),
                ExperienceTag(name: "Austria", emoji: "🇦🇹")
            ]
        ),
        Experience(
            title: "Tea in Turkey",
            type: .flow,
            startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 10)) ?? .now,
            endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 28)) ?? .now,
            tags: [
                ExperienceTag(name: "Winter", isSystem: true, emoji: "❄️"),
                ExperienceTag(name: "Skiing", emoji: "⛷️"),
                ExperienceTag(name: "Austria", emoji: "🇦🇹")
            ]
        )
    ]
    
    ViewableMultiExperienceDescriptor(experiences: experiences)
}
