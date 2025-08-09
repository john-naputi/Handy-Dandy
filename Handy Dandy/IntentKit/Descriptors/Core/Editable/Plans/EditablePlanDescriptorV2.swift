//
//  EditablePlanDescriptorV2.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct EditablePlanDescriptorV2: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var draft: DraftPlan
    private var mode: EditMode
    
    init(intent: EditablePlanIntent) {
        self.mode = intent.mode
        _draft = State(wrappedValue: DraftPlan(from: intent.data))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $draft.title)
                        .textInputAutocapitalization(.words)
                    TextField("Description (Optional)", text: $draft.notes, axis: .vertical)
                        .lineLimit(1...3)
                }
                
                Section("Kind") {
                    Picker("Plan Kind", selection: $draft.kind) {
                        ForEach(PlanKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                }
                
                Section("Type") {
                    Picker("Plan Type", selection: $draft.type) {
                        ForEach(PlanType.allCases) { type in
                            HStack(spacing: 8) {
                                Image(systemName: type.symbol)
                                    .foregroundStyle(type.tintColor)
                                Text(type.displayName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
//    let plan = Plan(title: "Grocery Shopping", kind: PlanKind.checklist, type: .shopping)
    let plan = Plan()
    let intent = EditablePlanIntent(data: plan, mode: .create)
    
    EditablePlanDescriptorV2(intent: intent)
}
