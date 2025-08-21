//
//  TaskListShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation

struct TaskListShadow: Equatable {
    let id: UUID
    let title: String
    let tasks: [TaskListItemShadow]
    
    var doneCount: Int { tasks.count(where: { $0.isDone }) }
    
    var remainingCount: Int {
        tasks.count - doneCount
    }
    
    var progress: Double {
        guard !tasks.isEmpty else { return Double(0) }
        return Double(doneCount) / Double(tasks.count)
    }
    
    var progressText: String {
        "\(remainingCount) of \(tasks.count) tasks remaining"
    }
    
    var progressPercent: String {
        // e.g., "60% done"
        let percent = Int(round(progress * 100))
        return "\(percent)%"
    }
    
    var progressPercentText: String {
        let percent = Int((progress * 100).rounded())
        return ("\(percent)% done")
    }
    
    // Sorting helper: todos first, then stable alpha by text
    var tasksTodosFirst: [TaskListItemShadow] {
        tasks.sorted{ (first, second) in
            switch (first.isDone, second.isDone) {
            case (false, true): return true
            case (true, false): return false
            default: return first.title.localizedCaseInsensitiveCompare(second.title) == .orderedAscending
            }
        }
    }
    
    func matches(query: String) -> Bool {
        let q = query.trimmed()
        guard !q.isEmpty else { return true }
        if title.localizedCaseInsensitiveContains(q) { return true }
        return tasks.contains { $0.title.localizedCaseInsensitiveContains(q) }
    }
    
    var isEmpty: Bool {
        tasks.isEmpty
    }
    
    var hasTasksRemaining: Bool {
        return remainingCount > 0
    }
    
    var firstTodo: TaskListItemShadow? {
        tasksTodosFirst.first(where: { !$0.isDone })
    }
    
    init(id: UUID, title: String, tasks: [TaskListItemShadow]) {
        self.id = id
        self.title = title
        self.tasks = tasks
    }
    
    func replacing(task: TaskListItemShadow) -> TaskListShadow {
        let newTasks = tasks.map { $0.id == task.id ? task : $0 }
        return TaskListShadow(id: id, title: title, tasks: newTasks)
    }
    
    func toggle(taskID: UUID) -> TaskListShadow {
        let newTasks = tasks.map { $0.id == taskID ? $0.toggled() : $0 }
        return TaskListShadow(id: id, title: title, tasks: newTasks)
    }
}
