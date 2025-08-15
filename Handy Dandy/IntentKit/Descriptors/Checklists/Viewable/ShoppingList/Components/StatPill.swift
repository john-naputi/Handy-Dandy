//
//  StatPill.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/15/25.
//

import SwiftUI

enum StatPillStyle {
    case neutral, good, warn, info
}

struct StatPill: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let label: String
    let value: String
    let style: StatPillStyle
    let icon: String?
    let compact: Bool
    
    init(label: String,
         value: String,
         style: StatPillStyle = .neutral,
         icon: String? = nil, compact: Bool = false
    ) {
        self.label = label
        self.value = value
        self.style = style
        self.icon = icon
        self.compact = compact
    }
    
    var body: some View {
        let colors = colorsForStyle(style)
        let vPadding: CGFloat = compact ? 6 : 8
        let hPadding: CGFloat = compact ? 10 : 12
        let spacing: CGFloat = compact ? 4 : 6
        
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: spacing) {
                if let icon {
                    Image(systemName: icon)
                        .imageScale(.small)
                        .font(.footnote)
                        .foregroundStyle(colors.fg.opacity(0.9))
                        .accessibilityHidden(true)
                }
                
                Text(label)
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(colors.fg.opacity(0.7))
            }
            
            Text(value)
                .font(compact ? .callout : .subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(colors.fg)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, vPadding)
        .padding(.horizontal, hPadding)
        .background(Capsule().fill(colors.bg))
        .overlay(Capsule().stroke(colors.stroke, lineWidth: colorScheme == .dark ? 0.5 : 0.75))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }
    
    private func colorsForStyle(_ style: StatPillStyle) -> (bg: Color, fg: Color, stroke: Color) {
        let base: (bg: Color, fg: Color) = {
            switch style {
            case .neutral: return (.secondary.opacity(colorScheme == .dark ? 0.18 : 0.12), .primary)
            case .good: return (.green.opacity(colorScheme == .dark ? 0.22 : 0.14), .green)
            case .warn: return (.orange.opacity(colorScheme == .dark ? 0.22 : 0.16), .orange)
            case .info: return (.blue.opacity(colorScheme == .dark ? 0.22 : 0.14), .blue)
            }
        }()
        
        let stroke = base.fg.opacity(colorScheme == .dark ? 0.35 : 0.25)
        return (bg: base.bg, fg: base.fg, stroke: stroke)
    }
}

#Preview {
    StatPill(
        label: "Budget",
        value: "$1.000,00",
        style: .good,
        icon: "wallet.pass"
    )
}
