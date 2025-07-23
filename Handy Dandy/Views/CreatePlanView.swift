//
//  CreatePlanView.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI
import Foundation

struct CreatePlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date = .now
    
    private let characterLimit = 30
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    LimitedTextInput(text: $title, limit: characterLimit) { text in
                        TextField("Checklist Title", text: text)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section(header: Text("Description")) {
                    LimitedTextInput(text: $description, limit: 150) { text in
                        TextEditor(text: text)
                            .frame(minHeight: 80, maxHeight: 150)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
                            .padding(.top, 8)
                    }
                }
                
                Section(header: Text("Plan Date")) {
                    DatePicker("Select a date", selection: $date, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            .navigationTitle("New Plan")
            .toolbar {
                ToolbarItem(placement: .confirmationAction, content: {
                    Button("Add Plan") {
                        let newPlan = Plan(title: title, description: description, planDate: date)
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
