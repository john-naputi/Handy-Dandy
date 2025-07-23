//
//  LimitedTextField.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/21/25.
//

import SwiftUI

struct LimitedTextInput<Content: View>: View {
    @Binding var text: String
    var limit: Int
    var content: (Binding<String>) -> Content
    
    var currentColor: Color {
        let threshold = Int(Double(limit) * 0.8)
        if text.count >= limit {
            return .red
        } else if text.count >= threshold {
            return .orange
        } else {
            return .black
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content($text)
                .onChange(of: text) { oldValue, newValue in
                    if newValue.count > limit {
                        text = String(newValue.prefix(limit))
                    }
                }
            
            Text("\(limit - text.count) characters remaining")
                .font(.caption)
                .foregroundStyle(currentColor)
                .animation(.linear, value: currentColor)
        }
    }
}

#Preview {
    LimitedTextFieldPreviewWrapper()
}

private struct LimitedTextFieldPreviewWrapper: View {
    @State private var previewText = ""
    
    var body: some View {
        LimitedTextInput(text: $previewText, limit: 50) { binding in
            TextField("Plan Title", text: binding)
                .textFieldStyle(.roundedBorder)
        }
            .padding()
    }
}
