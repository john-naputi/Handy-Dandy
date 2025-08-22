//
//  EditableSingleTaskPlanVIew.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import SwiftUI

struct EditableSingleTaskPlanView: View {
    @State var draft: DraftSingleTaskPlan
    var onCancel: () -> Void
    var onSave: (DraftSingleTaskPlan) -> Void
    
    @FocusState private var focused: Bool
    @State private var hasDue: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Task Name", text: $draft.title)
                        .focused($focused)
                        .submitLabel(.done)
                    Toggle("Completed", isOn: $draft.isDone)
                }
                
                Section("Notes") {
                    TextEditor(text: Binding(
                        get: { draft.notes ?? "" },
                        set: { draft.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 120)
                }
                
                Section("Schedule") {
                    Toggle("Has Due Date", isOn: $hasDue)
                    if hasDue {
                        DatePicker("Due", selection: Binding(
                            get: { draft.dueAt ?? Date() },
                            set: { draft.dueAt = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .bold()
                    .disabled(draft.title.trimmed().isEmpty)
                }
            }
            .onAppear {
                focused = true
                hasDue = draft.dueAt != nil
            }
        }
    }
    
    private func save() {
        draft.title = draft.title.trimmed()
        onSave(draft)
    }
}

#Preview {
    EditableSingleTaskPlanView(draft: .init(title: "Task"), onCancel: {}, onSave: {_ in })
}
