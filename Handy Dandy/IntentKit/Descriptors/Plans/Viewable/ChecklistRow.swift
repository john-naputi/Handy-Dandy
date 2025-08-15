//
//  ChecklistRow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/14/25.
//

import SwiftUI

struct ChecklistRow: View {
    let checklist: Checklist
    
    var body: some View {
        NavigationLink {
            if let list = checklist.shoppingList {
                ShoppingListDetailDescriptor(list: list)
            }
        } label: {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(checklist.title.isEmpty ? "Untitled" : checklist.title)
                        .font(.body)
                        .lineLimit(1)
                    Text(checklist.statusLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if checklist.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(Rectangle())
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    let checklist = Checklist(title: "Costco")
    ChecklistRow(checklist: checklist)
}
