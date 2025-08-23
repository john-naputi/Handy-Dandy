//
//  QuickTextSheet.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/22/25.
//

import SwiftUI

struct QuickTextSheet: View {
    @State private var text: String
    var title: String
    var isMultiline: Bool
    var placeholder: String
    var allowEmpty: Bool
    var onCancel: () -> Void
    var onSave: (String) -> Void
    
    init(initial: String,
         title: String,
         isMultiline: Bool,
         placeholder: String,
         allowEmpty: Bool,
         onCancel: @escaping () -> Void,
         onSave: @escaping (String) -> Void) {
        _text = State(initialValue: initial)
        self.title = title
        self.isMultiline = isMultiline
        self.placeholder = placeholder
        self.allowEmpty = allowEmpty
        self.onCancel = onCancel
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if isMultiline {
                    TextEditor(text: $text)
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if text.isEmpty {
                                    Text(placeholder)
                                        .foregroundStyle(.secondary)
                                        .padding(6)
                                }
                            }
                        )
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(text)
                    }
                    .bold()
                    .disabled(allowEmpty ? false : text.trimmed().isEmpty)
                }
            }
        }
    }
}

#Preview {
    QuickTextSheet(initial: "", title: "Edit Notes", isMultiline: false, placeholder: "Add notes...", allowEmpty: true, onCancel: {}, onSave: {_ in })
}
