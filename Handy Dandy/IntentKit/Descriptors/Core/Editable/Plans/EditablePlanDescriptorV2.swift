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
    private let onDone: (Plan, EditMode) -> Void
    
    init(
        intent: EditablePlanIntent,
        onDone: @escaping (Plan, EditMode) -> Void
    ) {
        self.mode = intent.mode
        self.onDone = onDone
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
            .navigationTitle(self.mode == .create ? "New Plan" : "Edit Plan")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(self.mode == .create ? "Create" : "Save") {
                        confirm()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func confirm() {
        switch mode {
        case .create:
            let plan = draft.materialize()
            modelContext.insert(plan)
            try? modelContext.save()
            
            onDone(plan, .create)
            dismiss()
        case .update:
            let plan = draft.boundPlan
            draft.move(to: plan)
            
            try? modelContext.save()
            
            onDone(plan, .update)
            dismiss()
        }
    }
}

#Preview {
    let plan = Plan()
    let intent = EditablePlanIntent(data: plan, mode: .create)
    
    EditablePlanDescriptorV2(intent: intent) { _, _ in
        
    }
}
