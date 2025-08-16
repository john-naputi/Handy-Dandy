//
//  SegmentedStatHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/16/25.
//

import SwiftUI

struct SegmentedStatHeader: View {
    struct Segment: Identifiable {
        let id: UUID
        let title: String
        let icon: String
        let value: String
        let tint: Color
        
        init(id: UUID = UUID(), title: String, icon: String, value: String, tint: Color) {
            self.id = id
            self.title = title
            self.icon = icon
            self.value = value
            self.tint = tint
        }
    }
    
    let segments: [Segment]
    
    var body: some View {
        HStack {
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                VStack(spacing: 2) {
                    Label(segment.title, systemImage: segment.icon)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                        .lineLimit(1)
                    
                    Text(segment.value)
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(segment.tint)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                
                if index < segments.count - 1 {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 1)
                        .padding(.vertical, 6)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SegmentedStatHeader(segments: [
        .init(title: "Budget", icon: "wallet.pass", value: "-", tint: .primary),
        .init(title: "Estimate", icon: "cart", value: "$0.00", tint: .primary),
        .init(title: "Δ", icon: "triangle.righthalf.filled", value: "$0.00", tint: .green)
    ])
}
