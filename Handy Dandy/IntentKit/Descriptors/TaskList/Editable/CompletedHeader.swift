//
//  CompletedHeader.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import SwiftUI

struct CompletedHeader: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var onClearCompleted: () -> Void
    
    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                Text("Completed")
                    .textCase(nil)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer(minLength: 8)
                Button(role: .destructive) { onClearCompleted() } label: { Text("Clear Completed").lineLimit(2) }
                    .accessibilityLabel("Clear completed tasks")
                    .accessibilityHint("Removes all completed tasks from this list")
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                Text("Completed").textCase(nil)
                Spacer(minLength: 8)
                Button(role: .destructive) { onClearCompleted() } label: { Text("Clear Completed").lineLimit(1) }
                    .accessibilityLabel("Clear completed tasks")
                    .accessibilityHint("Removes all completed tasks from this list")
            }
        }
    }
}

#Preview {
    CompletedHeader(onClearCompleted: {})
}
