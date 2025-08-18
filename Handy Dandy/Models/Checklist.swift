//
//  TaskItem.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import Foundation
import SwiftData

enum ChecklistKind: String, Identifiable, Codable, CaseIterable {
    case general, shoppingList
    
    var id: Self {
        self
    }
    
    var name: String {
        switch self {
        case .general:
            "General"
        case .shoppingList:
            "Shopping List"
        }
    }
}

@Model
final class Checklist {
    @Attribute(.unique) var id: UUID
    var title: String
    var checklistDescription: String
    var isComplete: Bool
    var kind: ChecklistKind
    
    @Relationship(deleteRule: .cascade, inverse: \ChecklistTask.checklist)
    var tasks: [ChecklistTask]
    
    @Relationship(deleteRule: .nullify)
    var plan: Plan?
    
    @Relationship(deleteRule: .cascade)
    var shoppingList: ShoppingList?
    
    var sortKey: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String = "",
        checklistDescription: String = "",
        isComplete: Bool = false,
        kind: ChecklistKind = .general,
        tasks: [ChecklistTask] = [],
        plan: Plan? = nil,
        shoppingList: ShoppingList? = nil,
        sortKey: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.kind = kind
        self.checklistDescription = checklistDescription
        self.plan = plan
        self.tasks = []
        self.shoppingList = shoppingList
        self.sortKey = sortKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.tasks.append(contentsOf: tasks)
        self.tasks.forEach { $0.checklist = self }
    }
}

extension Checklist {
    var sortedTasks: [ChecklistTask] {
        tasks.sorted {
            if $0.isComplete == $1.isComplete {
                return $0.title < $1.title
            }
            
            return !$0.isComplete && $1.isComplete
        }
    }
}

extension Checklist: TaskContainer {
    func name() -> String {
        return self.title
    }
    
    func description() -> String {
        return self.checklistDescription
    }
    
    
    func addTask(_ task: ChecklistTask) {
        tasks.append(task)
        updatedAt = .now
    }
    
    func removeTask(_ task: ChecklistTask) {
        tasks.removeAll(where: { $0.id == task.id })
        updatedAt = .now
    }
}

extension Checklist {
    var itemCount: Int {
        switch kind {
        case .shoppingList: return shoppingList?.items.count ?? 0
        case .general: return tasks.count
        }
    }
    
    var remainingCount: Int {
        switch kind {
        case .shoppingList:
            return shoppingList?.items.filter { !$0.isDone }.count ?? 0
        case .general: return  tasks.filter { !$0.isComplete }.count
        }
    }
    
    var statusLine: String {
        switch kind {
        case .shoppingList:
            guard let list = shoppingList else { return "0 Items" }
            let priced = list.pricedItemCount
            let total = list.items.count
            let estimatedLabel = list.estimateLabel.map { "• \($0)" } ?? ""
            let budget = list.budgetLabel.map { "• budget \($0)" } ?? ""
            
            return "\(total) items • \(priced)/\(total) priced • \(estimatedLabel)\(budget)"
        case .general:
            let done = itemCount - remainingCount
            return "\(done) of \(itemCount) Items"
        }
    }
    
    var isCompleted: Bool {
        switch kind {
        case .shoppingList:
            guard let list = shoppingList else { return false }
            return !list.items.isEmpty && list.items.allSatisfy { $0.isDone }
        case .general:
            return !tasks.isEmpty && tasks.allSatisfy { $0.isComplete }
        }
    }
    
    func recalcCompletion() {
        switch kind {
        case .shoppingList:
            isComplete = (shoppingList?.items.allSatisfy { $0.isDone } ?? false)
        case .general:
            isComplete = (!tasks.isEmpty && tasks.allSatisfy { $0.isComplete })
        }
        
        updatedAt = .now
    }
    
    func validate() -> Bool {
        switch kind {
        case .shoppingList: return shoppingList != nil
        case .general: return true
        }
    }
    
    func attach(to plan: Plan) {
        self.plan = plan
        if !plan.checklists.contains(where: { $0.id == id }) {
            plan.checklists.append(self)
        }
    }
    
    static func makeShoppingList(_ title: String, at place: Place? = nil) -> Checklist {
        let shoppingList = ShoppingList(title: title, place: place)
        
        return Checklist(title: title, kind: .shoppingList, shoppingList: shoppingList)
    }
    
    static func makeGeneral(_ title: String) -> Checklist {
        return Checklist(title: title, kind: .general)
    }
}
