//
//  LimitedTextEditorInput.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import SwiftUI

struct LimitedTextEditorInput: View {
    let sectionHeader: String
    let limit: Int = 150
    
    @Binding var inputText: String
    
    var body: some View {
        Section(header: Text(sectionHeader)) {
            LimitedTextInput(text: $inputText, limit: 150) { text in
                TextEditor(text: text)
                    .frame(minHeight: 80, maxHeight: 150)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    PreviewWrapper(inputText: "")
}

private struct PreviewWrapper: View {
    @State var inputText: String
    
    var body: some View {
        LimitedTextEditorInput(sectionHeader: "Description", inputText: $inputText)
    }
}
