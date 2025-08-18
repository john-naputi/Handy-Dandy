//
//  TaskListToreOrderingTests.swift
//  HandyDandy.Tests
//
//  Created by John Naputi on 8/18/25.
//

import Foundation
import Testing
import SwiftData
@testable import Handy_Dandy

@MainActor
@Suite("Task List Store Ordering Tests")
struct TaskListStoreOrderingTests {
    @Test("reorderExistingTasks: partial IDs keep others in stable order")
        func reorder_partialIDs_keepsOthersStable() throws {
            let (store, _) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false), ("D", false)])
            let ids = store.shadow!.tasks.map(\.id)

            // Only specify C, B → expect [C, B, A, D]
            let ordered = [ids[2], ids[1]]
            store.reorderExistingTasks(to: ordered)

            let result = store.shadow!.tasks.map(\.id)
            #expect(result == [ids[2], ids[1], ids[0], ids[3]])
        }

        @Test("reorderExistingTasks: duplicates & unknown IDs are ignored")
        func reorder_ignoresDuplicatesAndUnknowns() throws {
            let (store, _) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
            let ids = store.shadow!.tasks.map(\.id)
            let unknown = UUID()

            // Duplicates of A and an unknown id
            store.reorderExistingTasks(to: [ids[0], ids[0], unknown, ids[2]])

            // Expect prefix [A, C], then remaining [B] in original order
            let result = store.shadow!.tasks.map(\.id)
            #expect(result == [ids[0], ids[2], ids[1]])
        }

        // MARK: Indices after delete/clear/move

        @Test("deleteTask: reindexes sortIndex to 0..n-1")
        func delete_reindexesSequential() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
            let toDelete = store.shadow!.tasks[1].id   // delete B
            store.deleteTask(toDelete)

            // Read indices from the model (not the shadow)
            let sorted = list.tasks.sorted(by: { $0.sortIndex < $1.sortIndex })
            #expect(sorted.map(\.sortIndex) == Array(0..<sorted.count))
            #expect(sorted.map(\.text) == ["A", "C"])
        }

        @Test("clearCompleted: reindexes sortIndex to 0..n-1")
        func clearCompleted_reindexesSequential() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", true), ("B", false), ("C", true), ("D", false)])
            store.clearCompleted()

            // Model: canonical by sortIndex
            let sorted = list.tasks.sorted { $0.sortIndex < $1.sortIndex }

            // Indices are sequential
            #expect(sorted.map(\.sortIndex) == [0, 1])

            // Remaining texts are exactly B & D (order-agnostic)
            #expect(Set(sorted.map(\.text)) == Set(["B", "D"]))

            // Shadow reflects the same order as model
            #expect(store.shadow!.tasks.map(\.id) == sorted.map(\.id))
        }

        @MainActor
        @Test("moveTasks: real move updates order and indices")
        func move_updatesIndicesSequential() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])

            let beforeTexts = store.shadow!.tasks.map(\.text)
            let moved = beforeTexts[0]                        // "A"
            let others = Set(beforeTexts.dropFirst())         // {"B","C"}

            // Move first to post-removal end
            let src = IndexSet(integer: 0)
            let dest = store.shadow!.tasks.count - src.count  // 2

            #if DEBUG
            var saves = 0; store.onDidSave = { saves += 1 }
            #endif

            store.moveTasks(fromOffsets: src, toOffset: dest)

            #if DEBUG
            #expect(saves == 1)
            #endif

            let afterTexts = store.shadow!.tasks.map(\.text)

            // moved goes to end
            #expect(afterTexts.last == moved)

            // remaining (prefix) are the same set, order-agnostic
            #expect(Set(afterTexts.dropLast()) == others)

            // model persisted order == shadow; indices 0..n-1
            let ordered = list.tasks.sorted { $0.sortIndex < $1.sortIndex }
            #expect(ordered.map(\.id) == store.shadow!.tasks.map(\.id))
            #expect(ordered.map(\.sortIndex) == Array(0..<ordered.count))
        }

        // MARK: Timestamps & normalization

        @Test("reorderExistingTasks: does NOT change item updatedAt")
        func reorder_doesNotTouchItemTimestamps() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
            let before = Dictionary(uniqueKeysWithValues: list.tasks.map { ($0.id, $0.updatedAt) })

            let ids = store.shadow!.tasks.map(\.id).reversed()
            store.reorderExistingTasks(to: Array(ids))

            for t in list.tasks {
                #expect(t.updatedAt == before[t.id])
            }
        }

        @MainActor
        @Test("normalizeSortIndicesIfNeeded runs in init")
        func normalize_onInit_sequentializesIndices() throws {
            let ctx = try makeInMemoryContext()
            let list = TaskList(title: "Wonk")
            let a = TaskItem(text: "A", sortIndex: 10)
            let b = TaskItem(text: "B", sortIndex: 10)
            let c = TaskItem(text: "C", sortIndex: 5)
            list.tasks.append(contentsOf: [a, b, c])
            ctx.insert(list)
            try ctx.save()

            let store = TaskListStore(context: ctx, listID: list.id)

            // sortIndex is now 0,1,2 in display order
            let indices = list.tasks.sorted { $0.sortIndex < $1.sortIndex }.map(\.sortIndex)
            #expect(indices == [0, 1, 2])

            // First should be "C"; the other two can be either A/B depending on id tie-breaker
            let texts = store.shadow!.tasks.map(\.text)
            #expect(texts.first == "C")
            #expect(Set(texts.dropFirst()) == Set(["A","B"]))
        }

        // MARK: applyDraft rebuild specifics

        @Test("applyDraft: rebuild follows draft order & reindexes")
        func applyDraft_rebuild_orderAndIndices() throws {
            let (store, list) = try makeStoreWithSeed(tasks: [("A", false), ("B", false), ("C", false)])
            var draft = DraftTaskList(from: store.shadow!)

            // Make order: C, B, (new) D — drop A by not including it
            draft.items.removeAll()
            let ids = store.shadow!.tasks.map(\.id)
            draft.items.append(DraftTaskItem(id: ids[2], text: "C", isDone: false))
            draft.items.append(DraftTaskItem(id: ids[1], text: "B", isDone: true))
            draft.items.append(DraftTaskItem(id: UUID(), text: "D", isDone: false))

            store.applyDraft(draft)

            #expect(store.shadow!.tasks.map(\.text) == ["C", "B", "D"])
            let sorted = list.tasks.sorted(by: { $0.sortIndex < $1.sortIndex })
            #expect(sorted.map(\.text) == ["C", "B", "D"])
            #expect(sorted.map(\.sortIndex) == [0, 1, 2])
        }
}
