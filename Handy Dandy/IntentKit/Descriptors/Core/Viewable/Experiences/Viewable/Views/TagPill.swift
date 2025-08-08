//
//  TagPill.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/4/25.
//

import SwiftUI

struct TagPill: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var tag: ExperienceTag
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(tag.emoji ?? "") \(tag.name)")
                .font(.callout.weight(.semibold))
                .dynamicTypeSize(.xSmall ... .accessibility2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: true, vertical: false)
        }
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(tag.getColor(for: colorScheme).opacity(1))
        .foregroundStyle(tag.getColor(for: colorScheme).readableTextColor)
        .clipShape(Capsule())
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    let tag = ExperienceTag(name: "Skiing", isSystem: true, emoji: "🔄")
    TagPill(tag: tag)
}
