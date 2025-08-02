//
//  EditableExperienceDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

import SwiftUI

struct EditableExperienceDescriptor: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var draftExperience: DraftExperience
    var intent: EditableExperienceIntent
    
    init(intent: EditableExperienceIntent) {
        self.intent = intent
        _draftExperience = State(wrappedValue: DraftExperience(from: intent.data))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                SectionHeader(title: "Title", isRequired: true) {
                    TextField("", text: $draftExperience.title)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .stroke(intent.data.getColor(for: colorScheme), lineWidth: 1.5)
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white, lineWidth: 1)
                        )
                }

                SectionHeader(title: "Description", isRequired: false) {
                    let descriptionBinding = Binding<String>(
                        get: { draftExperience.description ?? "" },
                        set: { draftExperience.description = $0.isEmpty ? nil : $0 }
                    )
                    TextField("", text: descriptionBinding)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 32)
                        .background(
                            Capsule()
                                .stroke(intent.data.getColor(for: colorScheme), lineWidth: 1.5)
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white, lineWidth: 1)
                        )
                }

                SectionHeader(title: "Type", isRequired: true) {
                    Picker("Type", selection: $draftExperience.type) {
                        ForEach(ExperienceType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                        
                    }
                    .pickerStyle(.menu)
                }
                
                SectionHeader(title: "Dates", isRequired: true) {
                    DatePicker(
                        "Start Date",
                        selection: $draftExperience.startDate,
                        in: Date()...,
                        displayedComponents: .date,
                    )
                    
                    DatePicker(
                        "End Date",
                        selection: $draftExperience.endDate,
                        in: draftExperience.startDate...,
                        displayedComponents: .date
                    )
                    
                    EditableExperienceTagSection(draft: draftExperience)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                        intent.onCancel?()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let updated = draftExperience.to(experience: intent.data)
                        
                        for tag in draftExperience.tagsToDelete(from: intent.data) {
                            updated.tags.removeAll { $0.id == tag.id }
                            modelContext.delete(tag)
                        }
                        
                        let newTags = draftExperience.tagsToAdd(comparedTo: updated.tags)
                        for tag in newTags {
                            updated.add(tag)
                        }
                        
                        if intent.mode == .create {
                            modelContext.insert(updated)
                        }
                        
                        try? modelContext.save()
                        
                        dismiss()
                        intent.onSave?(updated)
                    } label: {
                        Text(getSubmissionTitle())
                    }
                    .disabled(draftExperience.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func getSubmissionTitle() -> String {
        return intent.mode == .create ? "Create" : "Update"
    }
}

#Preview {
    let experience = Experience()
    let intent = EditableExperienceIntent(data: experience, mode: .create)
    EditableExperienceDescriptorPreview(intent: intent)
}

fileprivate struct EditableExperienceDescriptorPreview: View {
    @State private var draft: DraftExperience = DraftExperience()
    var intent: EditableExperienceIntent
    
    var body: some View {
        EditableExperienceDescriptor(intent: intent)
    }
}
