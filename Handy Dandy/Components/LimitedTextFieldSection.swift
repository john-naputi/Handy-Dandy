//
//  LimitedTextFieldSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import SwiftUI

struct LimitedTextFieldSection: View {
    let header: String
    let limit: Int = 30
    let placeholder: String
    
    @Binding var text: String
    
    var body: some View {
        Section(header: Text(header)) {
            LimitedTextInput(text: $text, limit: limit) { text in
                TextField(placeholder, text: text)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

#Preview {
    PreviewWrapper(text: "Sample Text", title: "Sample Title")
}

private struct PreviewWrapper: View {
    @State var text: String
    @State var title: String
    
    var body: some View {
        LimitedTextFieldSection(header: "Name", placeholder: "Task name...", text: $text)
    }
}
