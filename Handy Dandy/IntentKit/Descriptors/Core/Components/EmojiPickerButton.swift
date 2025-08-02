//
//  EmojiPickerButton.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

import SwiftUI

struct EmojiPickerButton: View {
    @Binding var emoji: String
    @FocusState private var isFocused: Bool
    
    private let placeholder = "🙂"
    
    var body: some View {
        TextField(emoji.isEmpty ? placeholder : emoji, text: $emoji)
            .font(.title)
            .multilineTextAlignment(.center)
            .frame(width: 44, height: 44)
            .foregroundColor(emoji.isEmpty ? .secondary : .primary)
            .background(.gray.opacity(0.2))
            .clipShape(Circle())
            .focused($isFocused)
            .onTapGesture {
                isFocused = true
            }
            .onChange(of: emoji) { oldValue, newValue in
                let firstEmoji = newValue.unicodeScalars
                    .prefix(while: { $0.properties.isEmojiPresentation })
                    .reduce("") { $0 + String($1) }
                emoji = String(firstEmoji.prefix(6)) // Emoji flags and combined characters
            }
            .onTapGesture {
                isFocused = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
    }
}

#Preview {
    let emoji = ""
    
    EmojiPickerButtonPreview(emoji: emoji)
}

fileprivate struct EmojiPickerButtonPreview: View {
    @State var emoji: String = "😄"
    
    var body: some View {
        EmojiPickerButton(emoji: $emoji)
    }
}
