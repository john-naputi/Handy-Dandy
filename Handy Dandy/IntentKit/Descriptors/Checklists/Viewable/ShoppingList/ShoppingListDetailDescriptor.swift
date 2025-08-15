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
                ForEach(filteredItems) { item in
                    ItemRow(item: item, onToggleDone: {
                        self.toggleDone(item)
                    })
                }
            } header: {
                Text("Items")
            } footer: {
                // TODO: TotalsFooter()
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
                    // TODO: fill out
                } label: {
                    Image(systemName: "plus")
                }
                NavigationLink {
                    let intent = EditableIntent<ShoppingList, DraftShoppingList>(data: list, mode: .edit, outcome: { outcome in
                        if case .create(let draft) = outcome {
                            draft.apply(to: list, for: .create)
                            
                            try? modelContext.save()
                        }
                    })
                    
                    EditableShoppingListDescriptor(intent: intent)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                
                Menu {
                    Button {} label: { Label("Sort by Name", systemImage: "textformat") }
                    Button {} label: { Label("Sort by Price", systemImage: "dollarsign") }
                    Button {} label: { Label("Mark All Done", systemImage: "checkmark.circle") }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
    
    func indexFor(_ id: UUID) -> Int? {
        list.items.firstIndex(where: { $0.id == id })
    }
    
    func toggleDone(_ item: Item) {
        item.isDone.toggle()
        item.updatedAt = .now
        try? modelContext.save()
    }
}

#Preview {
//    let checklist = Checklist(title: "First Shopping List", kind: .shoppingList)
    let shoppingList = ShoppingList(title: "Costco")
    ShoppingListDetailDescriptor(list: shoppingList)
}
