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
    private let planId: UUID
    private let makeShadow: SingleTaskShadowFactory
    
    private(set) var shadow: SingleTaskShadow?
    private(set) var lastError: Error?
    
    #if DEBUG
    var onDidSave: (() -> Void)?
    var onShadowChanged: ((SingleTaskShadow?) -> Void)?
    #endif
    
    init(
        context: ModelContext,
        planId: UUID,
        makeShadow: @escaping SingleTaskShadowFactory = SingleTaskShadowRegistry.make)
    {
            self.context = context
            self.planId = planId
            self.makeShadow = makeShadow
        reload()
    }
    
    private func fetchPlan() throws -> Plan? {
        let descriptor = FetchDescriptor<Plan>(
            predicate: #Predicate { $0.planId == planId },
            sortBy: []
        )
        return try context.fetch(descriptor).first
    }
    
    private func reload() {
        do {
            guard let plan = try fetchPlan() else {
                shadow = nil
                return
            }
            
            if plan.singleTask == nil {
                let task = SingleTask(plan: plan)
                task.flavor = .from(planType: plan.type)
                task.payload = .general(.init(text: plan.title, notes: task.notes))
                plan.singleTask = task
                try context.save()
            }
            
            if let task = plan.singleTask {
                let derived = makeShadow(plan, task)
                shadow = .init(plan: plan, task: task, derived: derived)
            }
            
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func mutateIfChanged(_ apply: (_ plan: Plan, _ task: SingleTask) throws -> Bool) {
        do {
            guard let plan = try fetchPlan(), let task = plan.singleTask else { return }
            let changed = try apply(plan, task)
            guard changed else {
                lastError = nil
                return
            }
            plan.updatedAt = .now
            task.updatedAt = .now
            try context.save()
            
            let derived = makeShadow(plan, task)
            shadow = .init(plan: plan, task: task, derived: derived)
            
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
        mutateIfChanged { _, task in
            task.isDone.toggle()
            return true
        }
    }
    
    func setDone(_ value: Bool) {
        mutateIfChanged { _, task in
            guard task.isDone != value else { return false }
            task.isDone = value
            return true
        }
    }
    
    func setNotes(_ value: String?) {
        let text = value.trimmedOrNil
        mutateIfChanged { _, task in
            let before = task.notes
            if before == text { return false }
            task.notes = text
            
            return true
        }
    }
    
    func setDue(_ date: Date?) {
        mutateIfChanged { _, task in
            if task.dueAt == date { return false }
            task.dueAt = date
            
            return true
        }
    }
    
    func renamePlan(to value: String) {
        let title = value.trimmed()
        guard !title.isEmpty else { return }
        
        mutateIfChanged { plan, _ in
            guard plan.title != title else { return false }
            plan.title = title
            return true
        }
    }
    
    func updatePayload(_ transform: (inout SingleTaskPayload) -> Void) {
        mutateIfChanged { _, task in
            var payload = task.payload
            let before = payload
            
            transform(&payload)
            
            guard payload != before else { return false }
            task.payload = payload
            return true
        }
    }
    
    func applyDraft(_ draft: DraftSingleTaskPlan) {
        mutateIfChanged { plan, task in
            var changed = false
            
            let newTitle = draft.title.trimmed()
            if !newTitle.isEmpty, plan.title != newTitle {
                plan.title = newTitle
                changed = true
            }
            
            if task.isDone != draft.isDone {
                task.isDone = draft.isDone
                changed = true
            }
            
            let newNotes = draft.notes?.trimmed()
            if newNotes != task.notes {
                task.notes = newNotes
                changed = true
            }
            
            if task.dueAt != draft.dueAt {
                task.dueAt = draft.dueAt
                changed = true
            }
            
            return changed
        }
    }
}

extension SingleTaskStore {
    func makeDraft() -> DraftSingleTaskPlan?{
        do {
            guard let plan = try fetchPlan(), let task = plan.singleTask else { return nil }
            return DraftSingleTaskPlan(
                title: plan.title,
                notes: task.notes,
                dueAt: task.dueAt,
                isDone: task.isDone
            )
        } catch {
            return nil
        }
    }
}
