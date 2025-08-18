//
//  TaskListRepository.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/19/25.
//

import SwiftData
import Foundation

struct TaskListBridge {
    let context: ModelContext
    
    func fetchOrCreate(for plan: Plan) throws -> TaskList {
        if let existing = plan.taskLists.first { return existing }
        let taskList = TaskList(
            title: plan.title.isEmpty ? "Checklist" : plan.title,
            plan: plan
        )
        
        context.insert(taskList)
        try context.save()
        
        return taskList
    }
    
    func fetch(by id: UUID) throws -> TaskList? {
        var fetchDescriptor = FetchDescriptor<TaskList>()
        fetchDescriptor.predicate = #Predicate { $0.taskListId == id }
        fetchDescriptor.fetchLimit = 1
        
        return try context.fetch(fetchDescriptor).first
    }
}
