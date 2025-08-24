//
//  ShoppingListContainer.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/24/25.
//

import SwiftUI
import SwiftData
import Observation
import UIKit

enum ActiveSheet: Identifiable {
    case addItem
    case editItem(id: UUID)
    case editManualTotal
    case editBudget
    
    var id: String {
        switch self {
        case .addItem: return "add"
        case .editItem(let id): return id.uuidString
        case .editManualTotal: return "edit-manual-total"
        case .editBudget: return "edit-budget"
        }
    }
}

struct ShoppingListContainer: View {
    @Bindable var store: ShoppingListStore
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        NavigationStack {
            Group {
                if let shadow = store.shadow {
                    ShoppingListDetailDescriptor(
                        list: shadow,
                        items: store.items,
                        onTapEditBudget: { activeSheet = .editBudget },
                        onTapEditActual: { activeSheet = .editManualTotal },
                        onAdd: { activeSheet = .addItem },
                        onEdit: { id in activeSheet = .editItem(id: id) },
                        onToggle: { id in store.toggleItem(id) },
                        onDelete: { id in store.deleteItem(id) },
                        onMove: { from, to in store.reorder(from: from, to: to) },
                        onSortByName: { sortByName() },
                        onSortByPrice: { sortByPrice() },
                        onMarkAllDone: { markAllDone() }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    ProgressView("Loading...")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addItem:
                    EditShoppingListItemSheet(
                        draft: DraftItem(),
                        mode: .create,
                        currencyCode: store.shadow?.currencyCode ?? .usd,
                        onSave: { outcome in
                            handleItemOutcome(outcome)
                            activeSheet = nil
                        },
                        onCancel: {
                            activeSheet = nil
                        })
                case .editItem(let id):
                    if let base = store.items.first(where: { $0.id == id }) {
                        var draft = DraftItem(
                            id: base.id,
                            name: base.name,
                            notes: base.notes,
                            quantity: base.quantity,
                            unit: base.unit,
                            priority: base.priority,
                            isDone: base.isDone,
                            category: base.category,
                            customCategory: base.customCategory,
                            expectedUnitPrice: base.expectedUnitPrice
                        )
                        
                        EditShoppingListItemSheet(
                            draft: draft,
                            mode: .edit,
                            currencyCode: store.shadow?.currencyCode ?? .usd,
                            onSave: { outcome in
                                handleItemOutcome(outcome)
                                activeSheet = nil
                            },
                            onCancel: {
                                
                            }
                        )
                    }
                    
                case .editManualTotal:
                    EditableManualTotalSheet(
                        currencyCode: store.shadow?.currencyCode ?? .usd,
                        estimate: store.shadow?.estimatedFromItems ?? .zero,
                        existing: store.shadow?.actualTotalDisplay,
                        onOutcome: { outcome in
                            switch outcome {
                            case .save(let value): store.setActualTotal(max(0, value))
                            case .clear: store.setActualTotal(nil)
                            case .cancel: break
                            }
                            
                            activeSheet = nil
                        },
                        onCancel: { activeSheet = nil}
                    )
                    
                case .editBudget:
                    EditableManualTotalSheet(
                        currencyCode: store.shadow?.currencyCode ?? .usd,
                        estimate: store.shadow?.estimatedFromItems ?? .zero,
                        existing: store.shadow?.actualTotalDisplay,
                        onOutcome: { outcome in
                            switch outcome {
                            case .save(let value): store.setPlannedBudget(max(0, value))
                            case .clear: store.setPlannedBudget(nil)
                            case .cancel: break
                            }
                            
                            activeSheet = nil
                        },
                        onCancel: { activeSheet = nil }
                    )
                }
            }
        }
    }
    
    private func handleItemOutcome(_ outcome: EditableIntentOutcome<DraftItem>) {
        switch outcome {
        case .create(let draft):
            store.addItem(text: draft.name)
        case .update(let draft):
            store.editItem(draft.id, text: draft.name)
        default:
            assertionFailure("Unsupported outcome")
        }
    }
    
    private func sortByName() {
        applyReorder(to: store.items
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map(\.id)
        )
    }
    
    private func sortByPrice() {
        applyReorder(to: store.items
            .sorted {
                let first = $0.expectedUnitPrice ?? .zero
                let second = $1.expectedUnitPrice ?? .zero
                if first == second {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
                
                return first < second
            }
            .map(\.id)
        )
    }
    
    private func applyReorder(to ids: [UUID]) {
        var current = store.items.map(\.id)
        for (destination, id) in ids.enumerated() {
            guard let source = current.firstIndex(of: id), source != destination else {
                continue
            }
            
            store.reorder(from: IndexSet(integer: source), to: destination > source ? destination + 1 : destination)
            let element = current.remove(at: source)
            current.insert(element, at: destination)
        }
    }
    
    private func markAllDone() {
        for item in store.items where !item.isDone {
            store.toggleItem(item.id)
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    // Build an in-memory model container for preview
    struct Harness: View {
        @State private var store: ShoppingListStore

        init() {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: ShoppingList.self, Item.self, configurations: config)
            let ctx = container.mainContext

            // Seed a list + a few items
            let list = ShoppingList(title: "Costco", plannedBudget: 120)
            let milk = Item(name: "Milk", quantity: 2, unit: .each, expectedUnitPrice: 3.49, sortKey: 0)
            let chicken = Item(name: "Chicken Thighs", quantity: 1, unit: .lb, expectedUnitPrice: 9.99, sortKey: 1)
            let towels = Item(name: "Paper Towels", quantity: 1, unit: .pack, expectedUnitPrice: 19.99, sortKey: 2)
            list.add(milk); list.add(chicken); list.add(towels)

            ctx.insert(list)
            try? ctx.save()

            _store = State(initialValue: ShoppingListStore(context: ctx, listId: list.id))
        }

        var body: some View {
            ShoppingListContainer(store: store)
        }
    }

    return Harness()
}
