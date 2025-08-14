//
//  ShoppingListItemsSection.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/13/25.
//

import SwiftUI

struct ShoppingListItemsSection: View {
    @Binding var draft: DraftShoppingList
    var onAddItem: () -> Void
    var onEditItem: ((Binding<DraftItem>) -> Void)? = nil
    
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
                    .buttonStyle(.plain)
                    .foregroundStyle(draftItem.isDone ? Color.accentColor : Color.secondary)
                    
                    TextField("Item Name", text: item.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
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
                    onEditItem?(item)
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
                    
                    Button {
                        if let index = draft.items.firstIndex(where: { $0.id == draftItem.id }) {
                            withAnimation {
                                draft.items.insert(draftItem.duplicate(), at: index + 1)
                            }
                        }
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                }
            }
            .onMove { indices, newOffset in
                draft.items.move(fromOffsets: indices, toOffset: newOffset)
            }
            
            Button {
//                onAddItem(item)
            } label: {
                Label("Add Item", systemImage: "plus.circle")
                    .font(.body)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .clipShape(Capsule())
        }
        .animation(.default, value: draft.items)
    }
}

#Preview {
    let shoppingList = ShoppingList()
    let draft = DraftShoppingList(from: shoppingList)
    
    ShoppingListItemsSectionPreview(draft: draft, onAddItem: { })
}

fileprivate struct ShoppingListItemsSectionPreview: View {
    @State var draft: DraftShoppingList
    var onAddItem: () -> Void
    
    var body: some View {
        ShoppingListItemsSection(draft: $draft, onAddItem: onAddItem)
    }
}
