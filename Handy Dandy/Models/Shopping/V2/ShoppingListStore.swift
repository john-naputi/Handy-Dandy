//
//  ShoppingListStore.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/24/25.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class ShoppingListStore {
    private let context: ModelContext
    private let listId: UUID
    
    private(set) var shadow: ShoppingListShadow?
    private(set) var items: [ShoppingItemShadow] = []
    private(set) var lastError: Error?
    
    private let makeItem: (Item) -> ShoppingItemShadow
    
#if DEBUG
    var onDidSave: (() -> Void)?
    var onShadowChanged: ((ShoppingListShadow?) -> Void)?
#endif
    
    init(context: ModelContext, listId: UUID, makeItem: @escaping (Item) -> ShoppingItemShadow) {
        self.context = context
        self.listId = listId
        self.makeItem = makeItem
    }
    
    convenience init(context: ModelContext, listId: UUID) {
        self.init(
            context: context,
            listId: listId,
            makeItem: { item in
                ShoppingItemShadow(
                    id: item.id,
                    name: item.name,
                    notes: item.notes,
                    quantity: item.actualQuantity,
                    unit: item.unit,
                    isDone: item.isDone,
                    category: item.category,
                    sortKey: item.sortKey,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt
                )
            }
        )
    }
    
    func fetchList() throws -> ShoppingList? {
        let descriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        return try context.fetch(descriptor).first
    }
    
    private func reload() {
        do {
            if let list = try fetchList() {
                shadow = buildShadow(from: list)
                items = buildItemShadow(from: list)
            } else {
                shadow = nil
                items = []
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func mutateIfChanged(_ apply: (ShoppingList) throws -> Bool) {
        do {
            guard let list = try fetchList() else { return }
            let changed = try apply(list)
            guard changed else {
                lastError = nil
                return
            }
            
            list.updatedAt = .now
            try context.save()
            
            shadow = buildShadow(from: list)
            items = buildItemShadow(from: list)
            
            #if DEBUG
            onDidSave?()
            onShadowChanged?(shadow)
            #endif
            
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func buildShadow(from list: ShoppingList) -> ShoppingListShadow {
        var estimate: Decimal = .zero
        var actual: Decimal = .zero
        
        for item in list.items {
            if let price = item.expectedUnitPrice { estimate += price * max(0, item.quantity )}
            if let price = item.actualUnitPrice {
                actual += price * max(0, item.quantity )
            }
        }
        
        return ShoppingListShadow(
            id: list.id,
            title: list.title,
            notes: list.notes,
            currencyCode: list.currencyCode,
            budget: list.plannedBudget,
            manualActualTotal: list.manualActualTotal,
            sortKey: list.sortKey,
            createdAt: list.createdAt,
            updatedAt: list.updatedAt
        )
    }
    
    func buildItemShadow(from list: ShoppingList) -> [ShoppingItemShadow] {
        list.items.sorted { first, second in
            if first.sortKey != second.sortKey { return first.sortKey < second.sortKey }
            if first.createdAt != second.createdAt { return first.createdAt < second.createdAt }
            return first.id.uuidString < second.id.uuidString
        }
        .map {
            ShoppingItemShadow(
                id: $0.id,
                name: $0.name,
                notes: $0.notes,
                quantity: $0.quantity,
                actualQuantity: $0.actualQuantity,
                unit: $0.unit,
                isDone: $0.isDone,
                category: $0.category,
                sortKey: $0.sortKey,
                createdAt: $0.createdAt,
                updatedAt: $0.updatedAt
            )
        }
    }
    
    // MARK: Operations
    func addItem(text value: String) {
        let text = value.trimmed()
        guard !text.isEmpty else { return }
        
        mutateIfChanged { list in
            let index = nextSortIndex(for: list)
            list.items.append(Item(name: text, sortKey: index))
            
            return true
        }
    }
    
    func toggleItem(_ id: UUID) {
        mutateIfChanged { list in
            guard let item = list.items.first(where: { $0.id == id }) else { return false }
            item.isDone.toggle()
            return true
        }
    }
    
    func renameList(to value: String) {
        let name = value.trimmed()
        guard !name.isEmpty else { return }
        
        mutateIfChanged { list in
            guard list.title != name else { return false }
            list.title = name
            return true
        }
    }
    
    func editItem(_ id: UUID, text value: String) {
        let text = value.trimmed()
        guard !text.isEmpty else { return }
        
        mutateIfChanged { list in
            guard let item = list.items.first(where: { $0.id == id }) else { return false }
            guard item.name != text else { return false }
            item.name = text
            item.updatedAt = .now
            return true
        }
    }
    
    func deleteItem(_ id: UUID) {
        mutateIfChanged { list in
            let before = list.items.map(\.id)
            list.items.removeAll(where: { $0.id == id })
            guard list.items.map(\.id) != before else { return false }
            assignSortIndices(list.items)
            
            return true
        }
    }
    
    func setActualTotal(_ value: Decimal?) {
        mutateIfChanged { list in
            guard list.manualActualTotal != value else { return false }
            list.manualActualTotal = value
            if value == nil {
                list.items.forEach {
                    $0.actualUnitPrice = nil
                    $0.updatedAt = .now
                }
            }
            
            return true
        }
    }
    
    func setPlannedBudget(_ value: Decimal?) {
        mutateIfChanged { list in
            guard list.plannedBudget != value else { return false }
            list.plannedBudget = value
            return true
        }
    }
    
    func reorder(from source: IndexSet, to destination: Int) {
        mutateIfChanged { list in
            guard !source.isEmpty else { return false }
            var copy = list.items
            copy.move(fromOffsets: source, toOffset: destination)
            for (index, item) in copy.enumerated() { item.sortKey = index }
            list.items = copy
            
            return true
        }
    }
    
    // Do I want to have a TaskListStore#clearCompleted() method?
    func applyDraft(_ draft: DraftShoppingList) {
        mutateIfChanged { list in
            var changed = false
            var needsRebuild = false

            // 1) Top-level fields (title, notes, budget, currency, place)
            let newTitle = draft.name.trimmed()
            if !newTitle.isEmpty, list.title != newTitle {
                list.title = newTitle
                changed = true
            }

            let newNotes = draft.notes?.trimmed()
            if list.notes != newNotes {
                list.notes = newNotes
                changed = true
            }

            if list.plannedBudget != draft.plannedBudget {
                list.plannedBudget = draft.plannedBudget
                changed = true
            }

            if list.currencyCode != draft.currencyCode {
                list.currencyCode = draft.currencyCode
                changed = true
            }

            if list.place?.id != draft.place?.id {
                list.place = draft.place
                changed = true
            }

            // 2) Items: compute filtered/normalized draft,
            //    compare IDs/order to decide rebuild vs in-place edits
            let filteredDraft: [DraftItem] = draft.items
                .map { var d = $0; d.prepare(); return d }
                .filter { !$0.name.isEmpty }

            let existingById = Dictionary(uniqueKeysWithValues: list.items.map { ($0.id, $0) })

            let oldIds = list.items.map(\.id)
            let newIds = filteredDraft.map(\.id)

            if oldIds != newIds {
                changed = true
                needsRebuild = true
            }

            if !needsRebuild {
                // In-place updates only (don’t touch actuals)
                var seen = Set<UUID>()
                for d in filteredDraft where seen.insert(d.id).inserted {
                    if let existing = existingById[d.id] {
                        // DraftItem.apply() intentionally avoids touching actualQuantity/actualUnitPrice
                        d.apply(to: existing, for: .edit)
                        changed = true
                    } else {
                        // New item present without rebuild → fall back to rebuild path
                        needsRebuild = true
                    }
                }
            }

            // If nothing changed, skip save
            guard changed else { return false }

            if needsRebuild {
                // Build the exact sequence in draft order.
                var stitched = Set<UUID>()
                var newItems: [Item] = []
                newItems.reserveCapacity(filteredDraft.count)

                for d in filteredDraft where stitched.insert(d.id).inserted {
                    if let existing = existingById[d.id] {
                        // Update existing in-place to reflect draft fields (keep actuals)
                        d.apply(to: existing, for: .edit)
                        newItems.append(existing)
                    } else {
                        // New item (create with finalize; sets created/updated + next sortKey)
                        let created = d.finalize(list: list)
                        newItems.append(created)
                    }
                }

                // Replace + reindex
                assignSortIndices(newItems)
                list.items.removeAll(keepingCapacity: true)
                list.items.append(contentsOf: newItems)
            } else {
                // Only reindex to canonical indices without changing updatedAt (no touch unless needed)
                assignSortIndices(list.items)
            }

            return true
        }
    }
    
    // MARK: Internal Helpers
    private func nextSortIndex(for list: ShoppingList) -> Int {
        (list.items.map(\.sortKey).max() ?? -1) + 1
    }
    
    private func assignSortIndices(_ items: [Item], touchUpdatedAt: Bool = false) {
        for (index, item) in items.enumerated() {
            item.sortKey = index
            
            if touchUpdatedAt {
                item.updatedAt = .now
            }
        }
    }
    
    private func normalizeSortIndicesIfNeeded() {
        // TODO: Implement
    }
    
    private func canonicalOrder(_ items: [Item]) -> [Item] {
        items.sorted(by: canonicalLessThan)
    }
    
    private func canonicalLessThan(_ first: Item, _ second: Item) -> Bool {
        if first.sortKey != second.sortKey { return first.sortKey < second.sortKey }
        if first.createdAt != second.createdAt { return first.createdAt < second.createdAt }
        return first.id.uuidString < second.id.uuidString
    }
}
