//
//  CreateTaskSheet.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/23/25.
//

import SwiftUI

struct CreateTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    var onAdd: (DraftTask) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Info")) {
                    LimitedTextFieldSection(header: "Name", placeholder: "Buy eggs", text: $title)
                    LimitedTextFieldSection(header: "Description", placeholder: "2 dozen, not the 5 dozen", text: $description)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty else { return }
                        
                        let newTask = DraftTask(title: trimmedTitle, description: description.trimmingCharacters(in: .whitespacesAndNewlines))
                        onAdd(newTask)
                        
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateTaskSheet() { _ in
//        Just a holding spot
    }
}
