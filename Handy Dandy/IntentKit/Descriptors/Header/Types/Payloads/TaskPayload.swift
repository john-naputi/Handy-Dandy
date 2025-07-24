//
//  TaskPayload.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

struct TaskPayload<TContainer, TItem> {
    var container: TContainer
    var item: TItem
}

typealias SinglePlanTaskPayload = TaskPayload<Plan, Task>
typealias MultiPlanTaskPayload = TaskPayload<Plan, [Task]>
typealias SingleChecklistTaskPayload = TaskPayload<Checklist, Task>
typealias MultiChecklistTaskPayload = TaskPayload<Checklist, [Task]>
