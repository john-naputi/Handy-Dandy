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
        let icon: String?
        let value: String
        let tint: Color
        let isTappable: Bool
        let axLabel: String
        let axValue: String
        let axHint: String?
        
        init(id: UUID = UUID(),
             title: String,
             icon: String? = nil,
             value: String,
             tint: Color,
             isTappable: Bool = false,
             axLabel: String? = nil,
             axValue: String? = nil,
             axHint: String? = nil) {
            self.id = id
            self.title = title
            self.icon = icon
            self.value = value
            self.tint = tint
            self.isTappable = isTappable
            self.axLabel = axLabel ?? title
            self.axValue = axValue ?? value
            self.axHint = axHint
        }
    }
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let segments: [Segment]
    let onTap: ((Int) -> Void)?
    
    init(segments: [Segment], onTap: ((Int) -> Void)? = nil) {
        self.segments = segments
        self.onTap = onTap
    }
    
    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 0) {
                    segmentViews(isAxEnabled: true)
                }
            } else {
                HStack(spacing: 0) {
                    segmentViews(isAxEnabled: false)
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
        .accessibilityElement(children: .contain)
    }
    
    @ViewBuilder
    private func segmentViews(isAxEnabled: Bool) -> some View {
        ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
            let content = VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(segment.title)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    if let icon = segment.icon {
                        Image(systemName: icon)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(segment.value)
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.22), value: segment.value)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(segment.tint)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            
            if segment.isTappable {
                Button {
                    onTap?(index)
                } label: {
                    content
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(segment.axLabel))
                .accessibilityValue(Text(segment.axValue))
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(segment.axHint ?? "")
            } else {
                content
                    .accessibilityLabel(Text(segment.axLabel))
                    .accessibilityValue(Text(segment.axValue))
            }
            
            if index < segments.count - 1 && !isAxEnabled {
                Rectangle()
                    .fill(.separator.opacity(0.35))
                    .frame(width: 1)
                    .padding(.vertical, 6)
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview {
    SegmentedStatHeader(segments: [
        .init(title: "Budget", icon: "wallet.pass", value: "-", tint: .primary),
        .init(title: "Estimate", icon: "cart", value: "$0.00", tint: .primary),
        .init(title: "Δ", icon: "triangle.righthalf.filled", value: "$0.00", tint: .green)
    ])
}
