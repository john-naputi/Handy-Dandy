//
//  ShoppingListDetailDescriptor.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/14/25.
//

import SwiftUI

enum ItemFilter: CaseIterable {
    case all, toBuy, done
    
    var title: String {
        switch self{
        case .all: return "All"
        case .toBuy: return "To Buy"
        case .done: return "Done"
        }
    }
}

enum SortKind {
    case byName, byPrice
}

struct ShoppingListDetailDescriptor: View {
    @State private var filter: ItemFilter = .all
    @State private var editMode: EditMode = .inactive
    @State private var currentSort: SortKind = .byName
    @State private var showDetails: Bool = false
    
    let list: ShoppingListShadow
    let items: [ShoppingItemShadow]
    
    let onTapEditBudget: () -> Void
    let onTapEditActual: () -> Void
    let onAdd: () -> Void
    let onEdit: (_ id: UUID) -> Void
    let onToggle: (_ id: UUID) -> Void
    let onDelete: (_ id: UUID) -> Void
    let onMove: (_ from: IndexSet, _ to: Int) -> Void
    let onSortByName: () -> Void
    let onSortByPrice: () -> Void
    let onMarkAllDone: () -> Void
    
    private var isEditingItemsBinding: Binding<Bool> {
        Binding(
            get: { editMode == .active || editMode == .transient },
            set: { newValue in
                animateRespectingReduceMotion {
                    editMode = newValue ? .active : .inactive
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        )
    }
    
    private var filtered: [ShoppingItemShadow] {
        let base: [ShoppingItemShadow] = {
            switch filter {
            case .all: return items
            case .toBuy: return items.filter { !$0.isDone }
            case .done: return items.filter { $0.isDone }
            }
        }()
        
        return base.sorted { $0.sortKey < $1.sortKey }
    }
    
    var body: some View {
        List {
            ShoppingListHeader(list: list, onTapBudget: onTapEditBudget, onTapTotal: onTapEditActual)
            Section {
                FilterBar(filter: $filter)
                
                ForEach(filtered) { item in
                    ItemRow(
                        item: item,
                        currencyCode: list.currencyCode,
                        onToggleDone: { onToggle(item.id) }
                    )
                    .contextMenu {
                        Button(item.isDone ? "Mark Not Done" : "Mar as Done", systemImage: item.isDone ? "circle" : "checkmark.circle") {
                            onToggle(item.id)
                        }
                        Button("Edit", systemImage: "pencil") {
                            onEdit(item.id)
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            onDelete(item.id)
                        }
                    }
                }
                .onMove { source, destination in
                    guard filter == .all else { return }
                    onMove(source, destination)
                }
                .onDelete { indexSet in
                    let ids = indexSet.compactMap { filtered[safe:$0]?.id }
                    ids.forEach(onDelete)
                }
            } header: {
                ItemsHeader(
                    isEditingItems: isEditingItemsBinding,
                    currentSort: $currentSort,
                    addItem: onAdd,
                    sortByName: {
                        withAnimation(.easeInOut) { currentSort = .byName }
                        onSortByName()
                    },
                    sortByPrice: {
                        withAnimation(.easeInOut) { currentSort = .byPrice }
                        onSortByPrice()
                    },
                    markAllDone: {
                        withAnimation(.easeInOut) { onMarkAllDone() }
                    }
                )
                .disabled(filter != .all)
                .opacity(filter == .all ? 1 : 0.6)
                .accessibilityLabel("\(items.filter { !$0.isDone }.count) to buy, \(items.filter {$0.isDone }.count) are are done")
            }
            .headerProminence(.increased)
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    //    let checklist = Checklist(title: "First Shopping List", kind: .shoppingList)
    let shoppingList = ShoppingListShadow(title: "First Shopping List", budget: 100.0, manualActualTotal: 50.0, items: [])
    
    ShoppingListDetailDescriptor(list: shoppingList, items: shoppingList.items, onTapEditBudget: {}, onTapEditActual: {}, onAdd: {}, onEdit: { _ in }, onToggle: { _ in }, onDelete: { _ in }, onMove: { _, _ in }, onSortByName: {}, onSortByPrice: {}, onMarkAllDone: {})
}
