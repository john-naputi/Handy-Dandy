//
//  CreatePlanView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI

struct CreatePlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    
    private let characterLimit = 30
    
    var body: some View {
        NavigationStack {
            Form {
                LimitedTextInput(text: $title, limit: characterLimit) {
                    TextField("Checklist Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("New Plan")
            .toolbar {
                ToolbarItem(placement: .confirmationAction, content: {
                    Button("Add Plan") {
                        let newPlan = Plan(title: title)
                        modelContext.insert(newPlan)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                })
                
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
    CreatePlanView()
}
