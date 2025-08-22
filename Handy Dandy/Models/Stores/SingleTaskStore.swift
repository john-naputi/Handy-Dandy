//
//  SingleTaskStore.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SingleTaskStore {
    private let context: ModelContext
    private let taskId: UUID
    
    private(set) var shadow: SingleTaskShadow?
    private(set) var lastError: Error?
    
    #if DEBUG
    var onDidSave: (() -> Void)?
    var onShadowChanged: ((SingleTaskShadow?) -> Void)?
    #endif
    
    init(context: ModelContext, taskID: UUID) {
        self.context = context
        self.taskId = taskID
        reload()
    }
    
    private func fetchTask() throws -> SingleTask? {
        let descriptor = FetchDescriptor<SingleTask>(
            predicate: #Predicate { $0.uid == taskId },
            sortBy: []
        )
        return try context.fetch(descriptor).first
    }
    
    private func reload() {
        do {
            if let task = try fetchTask() {
                shadow = SingleTaskShadow(from: task)
            } else {
                shadow = nil
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func mutateIfChanged(_ apply: (SingleTask) throws -> Bool) {
        do {
            guard let task = try fetchTask() else { return }
            let changed = try apply(task)
            guard changed else {
                lastError = nil
                return
            }
            
            task.updatedAt = .now
            try context.save()
            
            let newShadow = SingleTaskShadow(from: task)
            shadow = newShadow
            
            #if DEBUG
            onDidSave?()
            onShadowChanged?(shadow)
            #endif
            
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    // MARK: Operations
    func toggle() {
        mutateIfChanged { task in
            task.isDone.toggle()
            return true
        }
    }
    
    func setDone(_ value: Bool) {
        mutateIfChanged { task in
            guard task.isDone != value else { return false }
            task.isDone = value
            return true
        }
    }
    
    func rename(to value: String) {
        let title = value.trimmed()
        guard !title.isEmpty else { return }
        
        mutateIfChanged { task in
            guard task.title != title else { return false }
            task.title = title
            return true
        }
    }
    
    func applyDraft(_ draft: DraftSingleTaskPlan) {
        mutateIfChanged { task in
            var changed = false
            let newTitle = draft.title.trimmed()
            if !newTitle.isEmpty, newTitle != task.title {
                task.title = newTitle
                return true
            }
            if draft.isDone != task.isDone {
                task.isDone = draft.isDone
                return true
            }
            
            return false
        }
    }
}
