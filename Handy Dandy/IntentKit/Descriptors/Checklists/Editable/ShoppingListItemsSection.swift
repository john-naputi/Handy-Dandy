//
//  ShoppingListItemsSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

struct ShoppingListItemsSection: View {
    @Binding var draft: DraftShoppingList
    var onAddTapped: () -> Void
    var onEditTapped: (UUID) -> Void
    
    var body: some View {
        Section("Items") {
            if draft.items.isEmpty {
                Text("No items yet. Add one to start.")
                    .foregroundStyle(.secondary)
            }
            
            ForEach($draft.items) { item in
                let draftItem = item.wrappedValue
                
                HStack {
                    Button {
                        item.wrappedValue.isDone.toggle()
                    } label: {
                        Image(systemName: draftItem.isDone ? "checkmark.circle.fill" : "circle")
                    }
                    .accessibilityLabel(draftItem.isDone ? "Mark as incomplete" : "Mark as complete")
                    .buttonStyle(.plain)
                    .foregroundStyle(draftItem.isDone ? Color.accentColor : Color.secondary)
                    
                    Text(draftItem.name.isEmpty ? "Untitled" : draftItem.name)
                        .lineLimit(1)
                    
                    Spacer()
                    Text("\(draftItem.quantity.formattedQuantity()) \(draftItem.unit.displayName)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    if let total = draftItem.lineTotalLabel(currency: draft.currencyCode) {
                        Text(total)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onEditTapped(item.id)
                }
                .contextMenu {
                    Button {
                        onEditTapped(item.id)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        if let index = draft.items.firstIndex(where: { $0.id == draftItem.id }) {
                            withAnimation(.snappy) {
                                draft.items.insert(draftItem.duplicate(), at: min(index + 1, draft.items.count))
                            }
                        }
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            draft.items.removeAll { $0.id == draftItem.id }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        item.wrappedValue.isDone.toggle()
                    } label: {
                        Label(draftItem.isDone ? "Incomplete" : "Complete", systemImage: "checkmark.circle")
                    }
                    .tint(.accentColor)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        if let index = draft.items.firstIndex(where: { $0.id == draftItem.id }) {
                            withAnimation {
                                draft.items.remove(at: index)
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onMove { indices, newOffset in
                draft.items.move(fromOffsets: indices, toOffset: newOffset)
            }
            
            Button(action: onAddTapped) {
                Label("Add Item", systemImage: "plus.circle")
                    .font(.body)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .clipShape(Capsule())
        }
        .animation(.snappy, value: draft.items)
    }
}

#Preview {
    let shoppingList = ShoppingList()
    let draft = DraftShoppingList(from: shoppingList)
    
    ShoppingListItemsSectionPreview(draft: draft, onAddTapped: {}, onEditTapped: { _ in })
}

fileprivate struct ShoppingListItemsSectionPreview: View {
    @State var draft: DraftShoppingList
    var onAddTapped: () -> Void
    var onEditTapped: (UUID) -> Void
    
    var body: some View {
        ShoppingListItemsSection(draft: $draft, onAddTapped: onAddTapped, onEditTapped: onEditTapped)
    }
}
