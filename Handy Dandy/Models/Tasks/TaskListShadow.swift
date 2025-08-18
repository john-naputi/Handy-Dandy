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
    let tasks: [TaskItemShadow]
    
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
    var tasksTodosFirst: [TaskItemShadow] {
        tasks.sorted{ (first, second) in
            switch (first.isDone, second.isDone) {
            case (false, true): return true
            case (true, false): return false
            default: return first.text.localizedCaseInsensitiveCompare(second.text) == .orderedAscending
            }
        }
    }
    
    func matches(query: String) -> Bool {
        let q = query.trimmed()
        guard !q.isEmpty else { return true }
        if title.localizedCaseInsensitiveContains(q) { return true }
        return tasks.contains { $0.text.localizedCaseInsensitiveContains(q) }
    }
    
    var isEmpty: Bool {
        tasks.isEmpty
    }
    
    var hasTasksRemaining: Bool {
        return remainingCount > 0
    }
    
    var firstTodo: TaskItemShadow? {
        tasksTodosFirst.first(where: { !$0.isDone })
    }
    
    init(id: UUID, title: String, tasks: [TaskItemShadow]) {
        self.id = id
        self.title = title
        self.tasks = tasks
    }
    
    init(from model: TaskList) {
        self.id = model.taskListId
        self.title = model.title
        let ordered = model.tasks.sorted {
            if $0.sortIndex != $1.sortIndex {
                return $0.sortIndex < $1.sortIndex
            }
            
            if $0.createdAt != $1.createdAt {
                return $0.createdAt < $1.createdAt
            }
            
            return $0.taskItemId.uuidString < $1.taskItemId.uuidString
        }
        
        self.tasks = ordered.map { TaskItemShadow(from: $0 )}
    }
    
    func replacing(task: TaskItemShadow) -> TaskListShadow {
        let newTasks = tasks.map { $0.id == task.id ? task : $0 }
        return TaskListShadow(id: id, title: title, tasks: newTasks)
    }
    
    func toggle(taskID: UUID) -> TaskListShadow {
        let newTasks = tasks.map { $0.id == taskID ? $0.toggle() : $0 }
        return TaskListShadow(id: id, title: title, tasks: newTasks)
    }
}
