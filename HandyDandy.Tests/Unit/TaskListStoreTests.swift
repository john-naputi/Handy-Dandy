//
//  TaskListStoreTests.swift
//  HandyDandy.Tests
//
//  Created by John Naputi on 8/18/25.
//

import Testing
import Foundation
import SwiftData
@testable import Handy_Dandy

@MainActor
@Suite("Task List Store Tests")
struct TaskListStoreTests {
    @Test("No-op applyDraft() skips save & shadow change")
    func noOpApplyDraftSkipsSave() async throws {
        let (store, _) = try makeStoreWithSeed(tasks: [("Buy Milk", false)])
        
        #if DEBUG
        var saves = 0, shadowChanges = 0
        store.onDidSave = { saves += 1 }
        store.onShadowChanged = { _ in shadowChanges += 1}
        #endif
        
        let original = store.shadow!
        let draft = DraftTaskList(from: original)
        
        store.applyDraft(draft)
        
        #if DEBUG
        #expect(saves == 0)
        #expect(shadowChanges == 0)
        #endif
        
        #expect(store.shadow?.title == original.title)
        #expect(store.shadow?.tasks.map(\.id) == original.tasks.map(\.id))
        #expect(store.shadow?.tasks.map(\.text) == original.tasks.map(\.text))
    }
    
    @Test("applyDraft: title+text change saves once and updates shadow")
    func applyDraftSavesOnce() throws {
        let (store, _) = try makeStoreWithSeed(tasks: [("Buy Oat Milk", false)])
        
        #if DEBUG
        var saves = 0
        store.onDidSave = { saves += 1}
        #endif
        
        var draft = DraftTaskList(from: store.shadow!)
        draft.title += "!"
        draft.items[0].text = "Buy oat milk"
        
        store.applyDraft(draft)
        
        #if DEBUG
        #expect(saves == 1)
        #endif
        
        #expect(store.shadow?.title == draft.title)
        #expect(store.shadow?.tasks.first?.text == "Buy oat milk")
    }
    
    @Test("moveTasks: no-op move skips save")
    func move_noChange_skipsSave() throws {
        let (store, _) = try makeStoreWithSeed(tasks: [
            ("A", false),
            ("B", false),
            ("C", false)
        ])
        
        #if DEBUG
        var saves = 0
        store.onDidSave = { saves += 1 }
        #endif
        
        store.moveTasks(fromOffsets: IndexSet(integer: 1), toOffset: 1)
        
        #if DEBUG
        #expect(saves == 0)
        #endif
    }
    
    @Test("clearCompleted: No completed items skips save")
    func clearCompleted_noOpSkipsSave() throws {
        let (store, _) = try makeStoreWithSeed(tasks: [("A", false), ("B", false)])
        
        #if DEBUG
        var saves = 0
        store.onDidSave = { saves += 1 }
        #endif
        
        store.clearCompleted()
        
        #if DEBUG
        #expect(saves == 0)
        #endif
        
        #expect(store.shadow?.tasks.count == 2)
    }
    
    @Test("reorderExistingTasks: real reorder saves once")
    func reorderSavesOnce() throws {
        let (store, _) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
        let originalIds = store.shadow!.tasks.map(\.id)
        let reordered = [originalIds[2], originalIds[0], originalIds[1]]
        
        #if DEBUG
        var saves = 0
        store.onDidSave = { saves += 1 }
        #endif
        
        store.reorderExistingTasks(to: reordered)
        
        #if DEBUG
        #expect(saves == 1)
        #endif
        
        #expect(store.shadow?.tasks.map(\.id) == reordered)
    }
    
    @Test("deleteTask: removes items and saves once")
    func deleteTaskSavesOnce() throws {
        let (store, _) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
        let idToDelete = store.shadow!.tasks[1].id
        
        #if DEBUG
        var saves = 0
        store.onDidSave = { saves += 1}
        #endif
        
        store.deleteTask(idToDelete)
        
        #if DEBUG
        #expect(saves == 1)
        #endif
        
        #expect(store.shadow?.tasks.contains(where: { $0.id == idToDelete }) == false)
        #expect(store.shadow?.tasks.count == 2)
    }
    
    @Test("addTask trims input, skips empty, appends with correct sortIndex")
        func addTask_trimsAndAppends() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("X", false)])

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            store.addTask(text: "   ")
            #if DEBUG
            #expect(saves == 0)
            #endif
            #expect(store.shadow!.tasks.map(\.text) == ["X"])

            store.addTask(text: "Y")
            #if DEBUG
            #expect(saves == 1)
            #endif

            // Order by sortIndex from the model to assert true persistence order
            let ordered = list.tasks.sorted { $0.sortIndex < $1.sortIndex }
            #expect(ordered.map(\.text) == ["X", "Y"])
            #expect(ordered.map(\.sortIndex) == [0, 1])
        }

        // MARK: renameList

        @Test("renameList trims and no-ops when unchanged")
        func renameList_noOpWhenSame() throws {
            let (store, _) = try makeStoreWithSeed(title: "Home", tasks: [("A", false)])

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            store.renameList(to: "  Home ")   // same after trim
            #if DEBUG
            #expect(saves == 0)
            #endif

            store.renameList(to: "New Home")
            #if DEBUG
            #expect(saves == 1)
            #endif

            #expect(store.shadow!.title == "New Home")
        }

        // MARK: editTask

        @Test("editTask no-ops when same text; updates text and timestamp when changed")
        func editTask_textChangeOnlyTouchesThatItem() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false)])
            let itemID = store.shadow!.tasks[0].id
            let modelItem = list.tasks.first(where: { $0.id == itemID })!
            let before = modelItem.updatedAt

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            // No-op (same text)
            store.editTask(itemID, text: "A")
            #if DEBUG
            #expect(saves == 0)
            #endif
            #expect(modelItem.updatedAt == before)

            // Real change
            store.editTask(itemID, text: "A+")
            #if DEBUG
            #expect(saves == 1)
            #endif
            #expect(store.shadow!.tasks.first!.text == "A+")
            #expect(modelItem.updatedAt != before)
        }

        // MARK: toggleTask

        @Test("toggleTask flips isDone and updates updatedAt; unknown id is no-op")
        func toggleTask_flipsAndTouchesTimestamp() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false)])
            let id = store.shadow!.tasks[0].id
            let modelItem = list.tasks.first(where: { $0.id == id })!
            let before = modelItem.updatedAt

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            store.toggleTask(id)
            #if DEBUG
            #expect(saves == 1)
            #endif
            #expect(store.shadow!.tasks.first!.isDone == true)
            #expect(modelItem.updatedAt != before)

            // Unknown id → no-op
            #if DEBUG
            let savesBefore = saves
            #endif
            store.toggleTask(UUID())
            #if DEBUG
            #expect(saves == savesBefore)
            #endif
        }

        // MARK: deleteTask / clearCompleted

        @Test("deleteTask unknown id is no-op; delete reindexes sequentially")
        func deleteTask_noOpUnknown_thenReindexes() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            // Unknown id → no-op
            store.deleteTask(UUID())
            #if DEBUG
            #expect(saves == 0)
            #endif

            // Delete B
            let deleteID = store.shadow!.tasks[1].id
            store.deleteTask(deleteID)
            #if DEBUG
            #expect(saves == 1)
            #endif

            // Model order by canonical key (sortIndex)
            let ordered = list.tasks.sorted { $0.sortIndex < $1.sortIndex }
            #expect(ordered.map(\.sortIndex) == [0, 1])
            #expect(Set(ordered.map(\.text)) == Set(["A", "C"]))   // order may be ["C","A"] or ["A","C"]

            // Shadow reflects the same persisted order
            #expect(Set(store.shadow!.tasks.map(\.text)) == Set(["A","C"]))
            #expect(store.shadow!.tasks.map(\.id) == ordered.map(\.id))
        }

        @Test("clearCompleted no-ops when none; removes completed and reindexes when present")
        func clearCompleted_behavesAsExpected() throws {
            // none completed
            do {
                let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false)])

                #if DEBUG
                var saves = 0
                store.onDidSave = { saves += 1 }
                #endif

                store.clearCompleted()
                #if DEBUG
                #expect(saves == 0)
                #endif
                #expect(list.tasks.count == 2)
            }

            // some completed
            do {
                let (store, list) = try makeStoreWithSeed(tasks: [("A", true), ("B", false), ("C", true)])

                #if DEBUG
                var saves = 0
                store.onDidSave = { saves += 1 }
                #endif

                store.clearCompleted()
                #if DEBUG
                #expect(saves == 1)
                #endif

                let ordered = list.tasks.sorted { $0.sortIndex < $1.sortIndex }
                #expect(ordered.map(\.text) == ["B"])
                #expect(ordered.map(\.sortIndex) == [0])
            }
        }

        // MARK: reorderExistingTasks

        @Test("reorderExistingTasks: empty list of ids is a no-op")
        func reorder_emptyIDs_isNoOp() throws {
            let (store, _) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
            let before = store.shadow!.tasks.map(\.id)

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            store.reorderExistingTasks(to: [])
            #if DEBUG
            #expect(saves == 0)
            #endif

            #expect(store.shadow!.tasks.map(\.id) == before)
        }

        // MARK: applyDraft

        @Test("applyDraft drops empty items, de-dups ids (first wins), preserves untouched updatedAt, and reindexes in draft order")
        func applyDraft_dedupAndOrder() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])

            // Capture B's timestamp to verify it's unchanged when untouched
            let ids = store.shadow!.tasks.map(\.id)
            let bID = ids[1]
            let bModel = list.tasks.first(where: { $0.id == bID })!
            let bBefore = bModel.updatedAt

            var draft = DraftTaskList(from: store.shadow!)
            // Build a new order: C, A(modified), (empty whitespace -> dropped), A(duplicate ignored), B(unchanged), D(new)
            draft.items.removeAll()
            draft.items.append(.init(id: ids[2], text: "C", isDone: false))              // C
            draft.items.append(.init(id: ids[0], text: "A1", isDone: false))             // A modified
            draft.items.append(.init(id: UUID(), text: "   ", isDone: false))            // empty -> drop
            draft.items.append(.init(id: ids[0], text: "A2", isDone: true))              // duplicate A -> ignored
            draft.items.append(.init(id: ids[1], text: "B", isDone: false))              // B unchanged
            draft.items.append(.init(id: UUID(), text: "D", isDone: false))              // new D

            #if DEBUG
            var saves = 0
            store.onDidSave = { saves += 1 }
            #endif

            store.applyDraft(draft)

            #if DEBUG
            #expect(saves == 1)
            #endif

            // Shadow reflects draft order with empties dropped and dup first-wins
            let texts = store.shadow!.tasks.map(\.text)
            #expect(texts == ["C", "A1", "B", "D"])

            // sortIndex sequential, persisted in model
            let ordered = list.tasks.sorted { $0.sortIndex < $1.sortIndex }
            #expect(ordered.map(\.text) == ["C", "A1", "B", "D"])
            #expect(ordered.map(\.sortIndex) == [0, 1, 2, 3])

            // B untouched → timestamp unchanged
            #expect(bModel.updatedAt == bBefore)
        }

        // MARK: Persistence check

        @Test("reorder persists across a new store (sortIndex is source of truth)")
        func reorder_persistsAcrossStoreInit() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
            let original = store.shadow!.tasks.map(\.id)
            let reordered = [original[2], original[0], original[1]]

            store.reorderExistingTasks(to: reordered)

            // New store, same context/id
            let store2 = TaskListStore(context: list.modelContext!, listID: list.id)
            #expect(store2.shadow!.tasks.map(\.id) == reordered)
        }
}
