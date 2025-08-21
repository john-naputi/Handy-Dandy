//
//  TaskListStore.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class TaskListStore {
    // Types
    struct RemovedTaskSnapshot: Identifiable {
        let id: UUID
        let text: String
        let isDone: Bool
        let createdAt: Date
        let updatedAt: Date
        let sortIndex: Int
    }
    
    enum RowEdit {
        case setText(String)
        case setDone(Bool)
    }
    
    private let makeItem: (TaskItem) -> TaskListItemShadow
    
    // Attributes
    private let context: ModelContext
    private let listID: UUID
    
    private(set) var shadow: TaskListShadow?
    private(set) var lastError: Error?
    
    #if DEBUG
    var onDidSave: (() -> Void)?
    var onShadowChanged: ((TaskListShadow?) -> Void)?
    #endif
    
    init(context: ModelContext, listID: UUID, makeItem: @escaping (TaskItem) -> TaskListItemShadow) {
        self.context = context
        self.listID = listID
        self.makeItem = makeItem
        reload()
        normalizeSortIndicesIfNeeded()
    }
    
    convenience init(context: ModelContext, listID: UUID) {
        self.init(
            context: context,
            listID: listID,
            makeItem: { task in
                TaskListItemShadow(payload: .general(.init(
                    id: task.taskItemId,
                    text: task.text,
                    isDone: task.isDone
                )))
            }
        )
    }
    
    private func reload() {
        do {
            if let list = try fetchList() {
                let items = list.tasks.sorted(by: canonicalLessThan).map(makeItem)
                shadow = TaskListShadow(id: list.taskListId, title: list.title, tasks: items)
            } else {
                shadow = nil
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func mutateIfChanged(_ apply: (TaskList) throws -> Bool) {
        do {
            guard let list = try fetchList() else { return }
            let changed = try apply(list)
            guard changed else {
                lastError = nil
                return
            }
            
            list.updatedAt = .now
            try context.save()
            
            let items = list.tasks.sorted(by: canonicalLessThan).map(makeItem)
            shadow = TaskListShadow(id: list.taskListId, title: list.title, tasks: items)
            
            #if DEBUG
            onDidSave?()
            onShadowChanged?(shadow)
            #endif
            
            // Avoid a second fetch. We already have the up-to-date model
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func fetchList() throws -> TaskList? {
        let descriptor = FetchDescriptor<TaskList>(
            predicate: #Predicate { $0.taskListId == listID }
        )
        
        return try context.fetch(descriptor).first
    }
        
    // MARK: - Operations
    func addTask(text raw: String) {
        let text = raw.trimmed()
        guard !text.isEmpty else {
            return
        }
        
        mutateIfChanged { list in
            let index = nextSortIndex(for: list)
            list.tasks.append(TaskItem(text: text, sortIndex: index))
            return true
        }
    }
    
    func toggleTask(_ id: UUID) {
        mutateIfChanged { list in
            guard let task = list.tasks.first(where: { $0.taskItemId == id }) else { return false }
            task.isDone.toggle()
            task.updatedAt = .now
            return true
        }
    }
    
    func renameList(to raw: String) {
        let title = raw.trimmed()
        guard !title.isEmpty else { return }
        
        mutateIfChanged { list in
            guard list.title != title else { return false }
            list.title = title
            return true
        }
    }
    
    func editTask(_ id: UUID, text raw: String) {
        let text = raw.trimmed()
        guard !text.isEmpty else { return }
        
        mutateIfChanged { list in
            guard let task = list.tasks.first(where: { $0.taskItemId == id }) else { return false }
            guard task.text != text else { return false }
            task.text = text
            task.updatedAt = .now
            return true
        }
    }
    
    func deleteTask(_ id: UUID) {
        mutateIfChanged { list in
            let before = list.tasks.map(\.taskItemId)
            list.tasks.removeAll(where: { $0.taskItemId == id })
            guard list.tasks.map(\.taskItemId) != before else { return false }
            assignSortIndices(list.tasks)
            
            return true
        }
    }
    
    func clearCompleted() {
        mutateIfChanged { list in
            let remaining = list.tasks.filter { !$0.isDone }
            let canonical = remaining.sorted {
                if $0.sortIndex != $1.sortIndex { return $0.sortIndex < $1.sortIndex }
                if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
                return $0.taskItemId < $1.taskItemId
            }
            
            guard canonical.map(\.taskItemId) != list.tasks.map(\.taskItemId) else { return false }
            
            assignSortIndices(canonical)
            list.tasks.removeAll(keepingCapacity: true)
            list.tasks.append(contentsOf: canonical)
            
            return true
        }
    }
    
    func moveTasks(fromOffsets source: IndexSet, toOffset destination: Int) {
        mutateIfChanged { list in
            guard !source.isEmpty else { return false }

            // Snapshot
            let current = list.tasks
            let beforeIDs = current.map(\.taskItemId)

            // Partition
            let removedIdxs = Array(source).sorted()
            let removedSet = Set(removedIdxs)
            var moved: [TaskItem] = []
            var kept:  [TaskItem] = []
            moved.reserveCapacity(removedIdxs.count)
            kept.reserveCapacity(current.count - removedIdxs.count)

            for (i, t) in current.enumerated() {
                if removedSet.contains(i) { moved.append(t) } else { kept.append(t) }
            }

            // POST-removal destination
            let dest = max(0, min(destination, kept.count))

            var newTasks = kept
            newTasks.insert(contentsOf: moved, at: dest)

            guard newTasks.map(\.taskItemId) != beforeIDs else { return false }

            // Persist order by sortIndex, don’t touch updatedAt
            assignSortIndices(newTasks)
            list.tasks.removeAll(keepingCapacity: true)
            list.tasks.append(contentsOf: newTasks)
            return true
        }
    }
    
    func reorderExistingTasks(to orderedIDs: [UUID]) {
        mutateIfChanged { list in
            let byId = Dictionary(uniqueKeysWithValues: list.tasks.map { ($0.taskItemId, $0 )})
            
            // 1. Take all items listed by orderedIDs, in that exact order (skip unknown and dupes)
            var seen = Set<UUID>()
            let prefix: [TaskItem] = orderedIDs.compactMap { id in
                guard seen.insert(id).inserted, let item = byId[id] else { return nil }
                return item
            }
            
            // 2. Append the rest (those not mentioned) by their current order (stable)
            let suffix = list.tasks.filter { !seen.contains($0.taskItemId) }
            let newTasks = prefix + suffix
            guard newTasks.map(\.taskItemId) != list.tasks.map(\.taskItemId) else { return false }
            
            assignSortIndices(newTasks)
            list.tasks.removeAll(keepingCapacity: true)
            list.tasks.append(contentsOf: newTasks)
            
            return true
        }
    }

    func applyDraft(_ draft: DraftTaskList) {
        mutateIfChanged { list in
            var changed = false
            var needsRebuild = false
            
            // 1. Title
            let newTitle = draft.title.trimmed()
            if !newTitle.isEmpty, newTitle != list.title {
                list.title = newTitle
                changed = true
            }
            
            let existingById = Dictionary(uniqueKeysWithValues: list.tasks.map { ($0.taskItemId, $0 )})
            let filteredDraft = draft.items
                .map { (id: $0.id, text: $0.text.trimmed(), isDone: $0.isDone )}
                .filter { !$0.text.isEmpty }
            
            let oldIds = list.tasks.map(\.taskItemId)
            let newIds = filteredDraft.map(\.id)
            if oldIds != newIds {
                changed = true
                needsRebuild = true
            }
            
            var seen = Set<UUID>()
            for draftItem in filteredDraft where seen.insert(draftItem.id).inserted {
                if let existingItem = existingById[draftItem.id] {
                    var itemChanged = false
                    if existingItem.text != draftItem.text {
                        existingItem.text = draftItem.text
                        itemChanged = true
                    }
                    
                    if existingItem.isDone != draftItem.isDone {
                        existingItem.isDone = draftItem.isDone
                        itemChanged = true
                    }
                    
                    if itemChanged {
                        existingItem.updatedAt = .now
                        changed = true
                    }
                } else {
                    // New Item. Make it rebuild.
                    changed = true
                    needsRebuild = true
                }
            }
            
            // Nothing changed. Skip save/reload.
            guard changed else { return false }
            
            if needsRebuild {
                var newTasks: [TaskItem] = []
                newTasks.reserveCapacity(filteredDraft.count)
                var stitched = Set<UUID>()
                for draftItem in filteredDraft where stitched.insert(draftItem.id).inserted {
                    if let existingItem = existingById[draftItem.id] {
                        newTasks.append(existingItem)
                    } else {
                        let task = TaskItem(text: draftItem.text, isDone: draftItem.isDone)
                        newTasks.append(task)
                    }
                }
                
                assignSortIndices(newTasks)
                list.tasks.removeAll(keepingCapacity: true)
                list.tasks.append(contentsOf: newTasks)
            }
            
            return true
        }
    }
    
    // MARK: Undo deletion actions
    @discardableResult
    func clearCompletedReturningSnapshots() -> [RemovedTaskSnapshot] {
        var snapshots: [RemovedTaskSnapshot] = []
        
        mutateIfChanged { list in
            let completed = list.tasks.filter { $0.isDone }
            guard !completed.isEmpty else { return false }
            
            snapshots = completed.map {
                .init(id: $0.taskItemId, text: $0.text, isDone: $0.isDone, createdAt: $0.createdAt, updatedAt: $0.updatedAt, sortIndex: $0.sortIndex)
            }
            
            let remaining = list.tasks.filter { !$0.isDone }
            
            // Canonical order for remaining items, then reindex
            let canonicalRemaining = canonicalOrder(remaining)
            assignSortIndices(canonicalRemaining)
            list.tasks.removeAll(keepingCapacity: true)
            list.tasks.append(contentsOf: canonicalRemaining)
            
            return true
        }
        
        return snapshots
    }
    
    func restore(_ snapshots: [RemovedTaskSnapshot]) {
        guard !snapshots.isEmpty else { return }
        
        mutateIfChanged { list in
            let restored: [TaskItem] = snapshots.map { snapshot in
                let taskItem = TaskItem(text: snapshot.text, isDone: snapshot.isDone, createdAt: snapshot.createdAt, updatedAt: snapshot.updatedAt, sortIndex: snapshot.sortIndex)
                
                return taskItem
            }
            
            // Merge, then re-apply canonical ordering and indices.
            var merged = list.tasks + restored
            merged = canonicalOrder(merged)
            assignSortIndices(merged)
            
            list.tasks.removeAll(keepingCapacity: true)
            list.tasks.append(contentsOf: merged)
            
            return true
        }
    }
    
    typealias RowMutation = (inout TaskItem) -> Void
    
    /// Mutate a single row in-place. We optimistically mark updated and save.
    /// Keep the mutation small and idempotent at call sites.
    func edit(_ id: UUID, mutate: RowMutation) {
        mutateIfChanged { list in
            guard let index = list.tasks.firstIndex(where: { $0.taskItemId == id }) else { return false}
            
            mutate(&list.tasks[index])
            list.tasks[index].updatedAt = .now
            return true
        }
    }
    
    // KeyPath setters (Equatable overloads)
    func set<V: Equatable>(
        _ id: UUID,
        _ keyPath: ReferenceWritableKeyPath<TaskItem, V>,
        to value: V,
        touchUpdatedAt: Bool = true
    ) {
        mutateIfChanged { list in
            guard let index = list.tasks.firstIndex(where: { $0.taskItemId == id }) else { return false }
            let before = list.tasks[index][keyPath: keyPath]
            guard before != value else { return false }
            list.tasks[index][keyPath: keyPath] = value
            if touchUpdatedAt {
                list.tasks[index].updatedAt = .now
            }
            
            return true
        }
    }
    
    func setOptional<V: Equatable>(
        _ id: UUID,
        _ keyPath: ReferenceWritableKeyPath<TaskItem, V?>,
        to value: V?,
        touchUpdatedAt: Bool = true
    ) {
        mutateIfChanged { list in
            guard let index = list.tasks.firstIndex(where: { $0.taskItemId == id }) else { return false }
            let before = list.tasks[index][keyPath: keyPath]
            guard before != value else { return false }
            list.tasks[index][keyPath: keyPath] = value
            if touchUpdatedAt {
                list.tasks[index].updatedAt = .now
            }
            
            return true
        }
    }
    
    // MARK: Internal helpers
    private func nextSortIndex(for list: TaskList) -> Int {
        (list.tasks.map(\.sortIndex).max() ?? -1) + 1
    }
    
    private func assignSortIndices(_ tasks: [TaskItem], touchUpdatedAt: Bool = false) {
        for (index, task) in tasks.enumerated() {
            task.sortIndex = index
            
            if touchUpdatedAt {
                task.updatedAt = .now
            }
        }
    }
    
    private func normalizeSortIndicesIfNeeded() {
        mutateIfChanged { list in
            let tasks = list.tasks
            let ordered = tasks.sorted {
                if $0.sortIndex != $1.sortIndex { return $0.sortIndex < $1.sortIndex }
                if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
                return $0.taskItemId.uuidString < $1.taskItemId.uuidString
            }
            
            let needs = Set(tasks.map(\.taskItemId)).count != tasks.count
            || !ordered.enumerated().allSatisfy { $0.element.sortIndex == $0.offset }
            
            guard needs else { return false }
            assignSortIndices(ordered)
            
            list.tasks.removeAll(keepingCapacity: true)
            list.tasks.append(contentsOf: ordered)
            
            return true
        }
    }
    
    private func canonicalOrder(_ tasks: [TaskItem]) -> [TaskItem] {
        tasks.sorted(by: canonicalLessThan)
    }
    
    private func canonicalLessThan(_ first: TaskItem, _ second: TaskItem) -> Bool {
        if first.sortIndex != second.sortIndex { return first.sortIndex < second.sortIndex }
        if first.createdAt != second.createdAt { return first.createdAt < second.createdAt }
        return first.taskItemId.uuidString < second.taskItemId.uuidString
    }
}
