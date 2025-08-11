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
    var intent: EditableIntent<Experience, DraftExperience>
    
    init(intent: EditableIntent<Experience, DraftExperience>) {
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
                        intent.outcome(.cancel)
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if intent.mode == .create {
                            intent.outcome(.create(draftExperience))
                        } else {
                            intent.outcome(.update(draftExperience))
                        }
                        
                        dismiss()
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
    let intent = EditableIntent<Experience, DraftExperience>(data: experience, mode: .create) { outcome in }
    EditableExperienceDescriptorPreview(intent: intent)
}

fileprivate struct EditableExperienceDescriptorPreview: View {
    @State private var draft: DraftExperience = DraftExperience()
    var intent: EditableIntent<Experience, DraftExperience>
    
    var body: some View {
        EditableExperienceDescriptor(intent: intent)
    }
}
