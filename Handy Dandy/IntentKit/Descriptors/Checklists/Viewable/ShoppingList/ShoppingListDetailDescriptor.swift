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

enum ActiveSheet: Identifiable {
    case addList
    case editList(id: UUID)
    case editManualTotal
    case editBudget
    
    var id: String {
        switch self {
        case .addList: return "add"
        case .editList(let id): return id.uuidString
        case .editManualTotal: return "edit-manual-total"
        case .editBudget: return "edit-budget"
        }
    }
}

struct ShoppingListDetailDescriptor: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var filter: ItemFilter = .all
    @State private var activeSheet: ActiveSheet? = nil
    @State var showDetails = false
    @State private var editMode: EditMode = .inactive
    @State private var isEditingItems = false
    @State private var currentSort: SortKind = .byName
    
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
    
    private var toBuyCount: Int {
        list.items.filter { !$0.isDone }.count
    }
    
    private var doneCount: Int {
        list.items.count - toBuyCount
    }
    
    let list: ShoppingList
    
    private var itemsEstimate: Decimal {
        list.items.reduce(0) { $0 + ($1.expectedPrice ?? 0) }
    }
    
    var body: some View {
        List {
            ShoppingListHeader(
                list: list,
                onTapBudget: {
                    activeSheet = .editBudget
                }, onTapTotal: {
                    activeSheet = .editManualTotal
                })
            Section {
                FilterBar(filter: $filter)
                    .animation(.easeInOut, value: filter)
                ForEach(filteredItems, id: \.id) { item in
                    ItemRow(item: item, onToggleDone: {
                        self.toggleDone(item)
                    })
                    .contextMenu {
                        Button(item.isDone ? "Mark as To Buy" : "Mark as Done", systemImage: item.isDone ? "circle" : "checkmark.circle") {
                            toggleDone(item)
                        }
                        Button("Edit", systemImage: "pencil") {
                            activeSheet = .editList(id: item.id)
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            if let index = indexInFiltered(item) {
                                deleteItems(at: IndexSet(integer: index))
                            }
                        }
                    }
                }
                .onMove { source, destination in
                    guard filter == .all else { return }
                    moveItems(from: source, to: destination)
                }
                .onDelete(perform: deleteItems)
            } header: {
                ItemsHeader(
                    isEditingItems: isEditingItemsBinding,
                    currentSort: $currentSort,
                    addItem: { activeSheet = .addList },
                    sortByName: {
                        animateRespectingReduceMotion({
                            sort(.byName)
                        })
                    },
                    sortByPrice: {
                        animateRespectingReduceMotion({
                            sort(.byPrice)
                        })
                    },
                    markAllDone: {
                        animateRespectingReduceMotion({
                            markAllDone()
                        })
                    }
                )
                .disabled(filter != .all).opacity(filter == .all ? 1 : 0.6)
                .accessibilityValue("\(toBuyCount) to buy, \(doneCount) done")
            }
            .headerProminence(.increased)
            
            Section {
                DisclosureGroup(isExpanded: $showDetails) {
                    // Read-only details; reuse formatting utilities!!!!!
                    if let notes = list.notes, !notes.isEmpty {
                        LabeledContent("Notes", value: notes)
                    }
                    
                    if let budget = list.plannedBudget {
                        LabeledContent("Budget", value: MoneyFormat.string(from: budget, code: list.currencyCode.iso))
                    } else {
                        LabeledContent("Budget", value: "N/A")
                    }
                    
                    LabeledContent("Created At", value: list.createdAt.formatted())
                    LabeledContent("Updated At", value: list.updatedAt.formatted())
                } label: {
                    Text("Details")
                }
            }
        }
        .navigationTitle(list.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
                .accessibilityLabel("Edit shopping list details")
            }
        }
        .onChange(of: filter) { _, newValue in
            if newValue != .all, (editMode == .active || editMode == .transient) {
                editMode = .inactive
                announce("Exited editing mode. Reordering is available only when the filter mode is set to 'All'")
            }
        }
        .sheet(item: $activeSheet) { which in
            switch which {
            case .addList:
                EditShoppingListItemSheet(
                    draft: DraftItem(),
                    mode: .create,
                    currencyCode: list.currencyCode,
                    onSave: { outcome in
                        animateRespectingReduceMotion({
                            handleItemOutcome(outcome)
                        })
                    },
                    onCancel: {
                        self.activeSheet = nil
                    }
                )
            case .editList(let id):
                if let index = indexFor(id) {
                    EditShoppingListItemSheet(
                        draft: DraftItem(from: list.items[index]),
                        mode: .edit,
                        currencyCode: list.currencyCode,
                        onSave: { outcome in
                            animateRespectingReduceMotion({
                                handleItemOutcome(outcome)
                            })
                        },
                        onCancel: {
                            self.activeSheet = nil
                        }
                    )
                }
            case .editManualTotal:
                EditableManualTotalSheet(currencyCode: list.currencyCode, estimate: itemsEstimate, existing: list.manualActualTotal, onOutcome: { outcome in
                    switch outcome {
                    case .save(let value):
                        animateRespectingReduceMotion({
                            list.manualActualTotal = max(0, value)
                            list.updatedAt = .now
                            try? modelContext.save()
                        })
                    case .clear:
                        animateRespectingReduceMotion({
                            list.manualActualTotal = nil
                            list.updatedAt = .now
                            try? modelContext.save()
                        })
                    case .cancel:
                        break
                    }
                    
                    activeSheet = nil
                }, onCancel: {
                    activeSheet = nil
                })
            case .editBudget:
                EditableManualTotalSheet(currencyCode: list.currencyCode, estimate: itemsEstimate, existing: list.plannedBudget, onOutcome: { outcome in
                    switch outcome {
                    case .save(let value):
                        animateRespectingReduceMotion({
                            list.plannedBudget = max(0, value)
                            list.updatedAt = .now
                        })
                        try? modelContext.save()
                    case .clear:
                        animateRespectingReduceMotion({
                            list.plannedBudget = nil
                            list.updatedAt = .now
                        })
                        try? modelContext.save()
                    case .cancel:
                        break
                    }
                    
                    activeSheet = nil
                }, onCancel: {
                    activeSheet = nil
                })
            }
        }
        .environment(\.editMode, $editMode)
    }
    
    // MARK: - Derived
    func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    private var filteredItems: [Item] {
        let base: [Item]
        
        switch filter {
        case .all: base = list.items
        case .toBuy: base = list.items.filter { !$0.isDone }
        case .done: base = list.items.filter { $0.isDone }
        }
        
        return base.sorted { $0.sortKey < $1.sortKey }
    }
    
    private var estimateTotal: Decimal {
        list.items.reduce(0) { $0 + ($1.expectedPrice ?? 0) }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        list.items.move(fromOffsets: source, toOffset: destination)
        normalizeSortKeys()
        
        do {
            touchList()
            try modelContext.save()
        } catch {
            #if DEBUG
            print("Failed to save item reorder: \(error)")
            #endif
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let ids = offsets.compactMap { filteredItems[safe: $0]?.id }
        for id in ids {
            if let index = list.items.firstIndex(where: { $0.id == id }) {
                let item = list.items.remove(at: index)
                modelContext.delete(item)
            }
        }
        
        normalizeSortKeys()
        touchList()
        try? modelContext.save()
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
        
        normalizeSortKeys()
        touchList()
        try? modelContext.save()
    }
    
    private func normalizeSortKeys() {
        for (index, item) in list.items.enumerated() {
            item.sortKey = index
        }
    }
    
    private func markAllDone() {
        for item in list.items {
            if !item.isDone {
                item.isDone = true
                item.updatedAt = .now
            }
        }
        
        touchList()
        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        announce("All items are marked as done")
    }
    
    func toggleDone(_ item: Item) {
        item.isDone.toggle()
        item.updatedAt = .now
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        touchList()
        try? modelContext.save()
    }
    
    private func touchList() {
        list.updatedAt = .now
    }
    
    private func handleItemOutcome(_ outcome: EditableIntentOutcome<DraftItem>) {
        switch outcome {
        case .create(let draft):
            let newItem = draft.finalize(list: list)
            list.items.append(newItem)
            normalizeSortKeys()
            
            try? modelContext.save()
        case .update(let draft):
            if let index = indexFor(draft.id) {
                draft.apply(to: list.items[index], for: .edit)
                try? modelContext.save()
            }
        default:
            assertionFailure("Invalid operation for create or edit action.")
        }
        
        self.activeSheet = nil
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
    let shoppingList = ShoppingList(title: "Costco", plannedBudget: Decimal(100), manualActualTotal: Decimal(123.54))
    ShoppingListDetailDescriptor(showDetails: true, list: shoppingList)
}
