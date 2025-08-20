//
//  RenameTaskSheet.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/19/25.
//

import SwiftUI

struct RenameTaskSheet: View {
    @State private var text: String
    var onCancel: () -> Void
    var onSave: (String) -> Void
    
    init(initial: String, onCancel: @escaping () -> Void, onSave: @escaping (String) -> Void) {
        _text = State(initialValue: initial)
        self.onCancel = onCancel
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $text)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit{ save() }
                }
            }
            .navigationTitle("Rename Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(text.trimmed().isEmpty)
                }
            }
        }
    }
    
    private func save() {
        onSave(text.trimmed())
    }
}

#Preview {
    RenameTaskSheet(initial: "Buy Gels", onCancel: {}, onSave: {_ in })
}
