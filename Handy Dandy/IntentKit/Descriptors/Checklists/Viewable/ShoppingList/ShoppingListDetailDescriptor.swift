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

private enum SortKind {
    case byName, byPrice
}

enum ActiveSheet: Identifiable {
    case add
    case edit(id: UUID)
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let id): return id.uuidString
        }
    }
}

struct ShoppingListDetailDescriptor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var filter: ItemFilter = .all
    @State private var activeSheet: ActiveSheet? = nil
    @State private var showDetails = false
    
    let list: ShoppingList
    
    var body: some View {
        List {
            ShoppingListHeader(list: list)
            Section {
                FilterBar(filter: $filter)
                ForEach(filteredItems, id: \.id) { item in
                    ItemRow(item: item, onToggleDone: {
                        self.toggleDone(item)
                    })
                    .swipeActions(edge: .trailing) {
                        Button {
                            toggleDone(item)
                        } label: {
                            Label(item.isDone ? "Undo" : "Done", systemImage: "checkmark.circle")
                        }
                        .tint(.green)
                        
                        Button{
                            activeSheet = .edit(id: item.id)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            if let index = indexInFiltered(item) {
                                deleteItems(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove { source, destination in
                    guard filter == .all else { return }
                    moveItems(from: source, to: destination)
                }
                .onDelete(perform: deleteItems)
            } header: {
                Text("Items")
            } footer: {
                TotalsFooter(estimate: estimateTotal, budget: list.plannedBudget, delta: delta)
            }
            
            Section(isExpanded: $showDetails) {
                // Read-only details; reuse formatting utilities!!!!!
                if let notes = list.notes, !notes.isEmpty {
                    LabeledContent("Notes", value: notes)
                }
                
                LabeledContent("Budget", value: MoneyFormat.string(list.plannedBudget ?? 0, code: list.currencyCode.iso) ?? "N/A")
                LabeledContent("Created At", value: list.createdAt.formatted())
                LabeledContent("Updated At", value: list.updatedAt.formatted())
            } header: {
                Text("Details")
            }
        }
        .navigationTitle(list.title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                }
                
                NavigationLink {
                    let intent = EditableIntent<ShoppingList, DraftShoppingList>(
                        data: list,
                        mode: .edit,
                        outcome: { outcome in
                            // Prefer .update for edit screens
                            if case .update(let draft) = outcome {
                                draft.apply(to: list, for: .edit)
                                try? modelContext.save()
                            }
                        }
                    )
                    EditableShoppingListDescriptor(intent: intent)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                
                Menu {
                    Button {
                        self.sort(.byName)
                    } label: {
                        Label("Sort by Name", systemImage: "textformat")
                    }
                    Button {
                        self.sort(.byPrice)
                    } label: {
                        Label("Sort by Price", systemImage: "dollarsign")
                    }
                    Button {
                        markAllDone()
                    } label: {
                        Label("Mark All Done", systemImage: "checkmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $activeSheet) { which in
            switch which {
            case .add:
                EditShoppingListItemSheet(
                    draft: DraftItem(),
                    mode: .create,
                    currencyCode: list.currencyCode,
                    onSave: { draft in
                        
                    },
                    onCancel: {
                        self.activeSheet = nil
                    }
                )
            case .edit(let id):
                if let index = indexFor(id) {
                    EditShoppingListItemSheet(
                        draft: DraftItem(from: list.items[index]),
                        mode: .edit,
                        currencyCode: list.currencyCode,
                        onSave: { draft in
                            print("Do something here")
                        },
                        onCancel: {
                            self.activeSheet = nil
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Derived
    
    private var filteredItems: [Item] {
        switch filter {
        case .all: return list.items
        case .toBuy: return list.items.filter { !$0.isDone }
        case .done: return list.items.filter { $0.isDone }
        }
    }
    
    private var estimateTotal: Decimal {
        list.items.reduce(0) { $0 + ($1.expectedUnitPrice ?? 0) }
    }
    
    private var delta: Decimal {
        estimateTotal - (list.plannedBudget ?? 0)
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        list.items.move(fromOffsets: source, toOffset: destination)
        
        // Normalize and persist stable order
        for (index, item) in list.items.enumerated() {
            item.sortKey = index
        }
        
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("Failed to save item reorder: \(error)")
            #endif
        }
    }
    
    private func sort(_ kind: SortKind) {
        switch kind {
        case .byName:
            list.items.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .byPrice:
            list.items.sort {
                let first = $0.expectedPrice ?? 0
                let second = $1.expectedPrice ?? 0
                
                return first == second ? $0.name < $1.name : first < second
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let ids = offsets.compactMap { filteredItems[safe: $0]?.id }
        list.items.removeAll(where: { ids.contains($0.id) })
        try? modelContext.save()
    }
    
//    private func deleteItems(with offsets: IndexSet) {
//        deleteItems(at: offsets)
//    }
    
    private func markAllDone() {
        for item in list.items {
            if !item.isDone {
                item.isDone = true
                item.updatedAt = .now
            }
        }
    }
    
    func toggleDone(_ item: Item) {
        item.isDone.toggle()
        item.updatedAt = .now
        try? modelContext.save()
    }
    
    private func handleItemOutcome(_ outcome: EditableIntentOutcome<DraftItem>) {
        switch outcome {
        case .create(let draft):
            let newItem = draft.finalize(list: list)
            list.items.append(newItem)
            for (index, item) in list.items.enumerated() {
                item.sortKey = index
            }
            
            try? modelContext.save()
        case .update(let draft):
            if let index = indexFor(draft.id) {
                draft.apply(to: list.items[index], for: .edit)
                try? modelContext.save()
            }
        default:
            assertionFailure("Invalid operation for create or edit action.")
        }
    }
    
    private func indexFor(_ id: UUID) -> Int? {
        list.items.firstIndex(where: { $0.id == id })
    }
    
    private func indexInFiltered(_ item: Item) -> Int? {
        filteredItems.firstIndex(where: { $0.id == item.id })
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
//    let checklist = Checklist(title: "First Shopping List", kind: .shoppingList)
    let shoppingList = ShoppingList(title: "Costco")
    ShoppingListDetailDescriptor(list: shoppingList)
}
