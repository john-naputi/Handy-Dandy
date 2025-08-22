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
    var onCancel: () -> Void
    var onSave: (String) -> Void
    
    init(initial: String,
         title: String,
         isMultiline: Bool,
         placeholder: String,
         onCancel: @escaping () -> Void,
         onSave: @escaping (String) -> Void) {
        _text = State(initialValue: initial)
        self.title = title
        self.isMultiline = isMultiline
        self.placeholder = placeholder
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
                    .disabled(text.trimmed().isEmpty)
                }
            }
        }
    }
}

#Preview {
    QuickTextSheet(initial: "", title: "Edit Notes", isMultiline: false, placeholder: "Add notes...", onCancel: {}, onSave: {_ in })
}
