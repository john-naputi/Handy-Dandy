//
//  TestHelpers.swift
//  HandyDandy.Tests
//
//  Created by John Naputi on 8/18/25.
//

import SwiftData
@testable import Handy_Dandy

func makeInMemoryContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: TaskList.self, TaskItem.self, configurations: config)
    
    return ModelContext(container)
}

@discardableResult
func seedList(_ context: ModelContext, title: String = "Home", tasks: [(String, Bool)]) throws -> TaskList {
    let list = TaskList(title: title)
    for (text, done) in tasks {
        let task = TaskItem(text: text, isDone: done)
        list.tasks.append(task)
    }
    
    context.insert(list)
    try context.save()
    
    return list
}

@MainActor
func makeStoreWithSeed(
    title: String = "Home",
    tasks: [(String, Bool)]
) throws -> (store: TaskListStore, list: TaskList) {
    let context = try makeInMemoryContext()
    let list = try seedList(context, title: title, tasks: tasks)
    let store = TaskListStore(context: context, listID: list.id)
    
    return (store, list)
}
