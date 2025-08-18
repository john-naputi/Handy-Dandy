//
//  EditablePlanDescriptorV2.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/8/25.
//

import SwiftUI

struct EditablePlanDescriptorV2: View {
    @Environment(\.dismiss) private var dismiss
//    @Environment(\.modelContext) private var modelContext
    
    @State private var draft: DraftPlan
    private let intent: EditableIntent<Plan, DraftPlan>
    
    init(intent: EditableIntent<Plan, DraftPlan>) {
        self.intent = intent
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
                        ForEach(draft.kind.allowedPlanTypes) { type in
                            HStack(spacing: 8) {
                                Image(systemName: type.symbol)
                                    .foregroundStyle(type.tintColor)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                }
            }
            .navigationTitle(self.intent.mode == .create ? "New Plan" : "Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        intent.outcome(.cancel)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(self.intent.mode == .create ? "Create" : "Save") {
                        switch self.intent.mode {
                        case .create:
                            intent.outcome(.create(draft))
                        case .edit:
                            intent.outcome(.update(draft))
                        }
                        
                        dismiss()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // TODO: The caller is now responsible for this. Keep the editors small.
//    private func confirm() {
//        switch mode {
//        case .create:
//            let plan = draft.materialize()
//            modelContext.insert(plan)
//            try? modelContext.save()
//            
//            onDone(plan, .create)
//            dismiss()
//        case .update:
//            let plan = draft.boundPlan
//            draft.move(to: plan)
//            
//            try? modelContext.save()
//            
//            onDone(plan, .update)
//            dismiss()
//        }
//    }
}

#Preview {
    let plan = Plan()
    let intent = EditableIntent<Plan, DraftPlan>(data: plan, mode: .create) { outcome in
        // Keeping blank for the preview
    }
    
    EditablePlanDescriptorV2(intent: intent)
}
