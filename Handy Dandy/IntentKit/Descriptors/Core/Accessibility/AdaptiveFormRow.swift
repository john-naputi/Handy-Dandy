//
//  AdaptiveFormRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/10/25.
//

import SwiftUI

enum HelpMessage: Equatable {
    case none
    case info(String)
    case warning(String)
    case error(String)
    
    var text: String? {
        switch self {
        case .none: return nil
        case .info(let message), .warning(let message), .error(let message): return message
        }
    }
    
    enum Kind {
        case info, warning, error
    }
    
    var kind: Kind? {
        switch self {
        case .none: return nil
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}

struct AdaptiveFormRow<Content: View>: View {
    let label: String
    let labelNote: String?
    let isAxSize: Bool
    let helpMessage: HelpMessage
    let allyLabel: String?
    let forceStacked: Bool
    private let content: () -> Content

    // single decision: stack if AX or caller forces it
    private var useStacked: Bool { forceStacked || isAxSize }

    var body: some View {
        Group {
            if useStacked { stackedBody } else { inlineBody }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(allyLabel ?? label))
    }

    // MARK: - Pieces

    private var stackedBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            labelBlock(stacked: true)
            content()
            helpView
        }
    }

    private var inlineBody: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            labelBlock(stacked: false)
                .frame(width: 110, alignment: .leading)
            VStack(alignment: .leading, spacing: 6) {
                content()
                helpView
            }
        }
    }

    @ViewBuilder
    private func labelBlock(stacked: Bool) -> some View {
        if stacked {
            VStack(alignment: .leading, spacing: 2) {
                titleLabel
                if let note = labelNote { noteLabel(note) }
            }
        } else {
            HStack(spacing: 6) {
                titleLabel
                if let note = labelNote { noteLabel(note) }
            }
        }
    }

    private var titleLabel: some View {
        Text(label)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func noteLabel(_ text: String) -> some View {
        Text(text).font(.subheadline).foregroundStyle(.secondary)
    }

    @ViewBuilder
    private var helpView: some View {
        if let text = helpMessage.text, let kind = helpMessage.kind {
            Text(text)
                .font(.footnote)
                .foregroundStyle(
                    kind == .error ? .red : (kind == .warning ? .orange : .secondary)
                )
                .accessibilitySortPriority(1)
        }
    }
}

#Preview {
    AdaptiveFormRow(label: "Form Row", isAxSize: true, helpMessage: .none) {
        Text("This is some helpful text.")
    }
}
