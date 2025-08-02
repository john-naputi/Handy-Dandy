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

typealias SinglePlanTaskPayload = TaskPayload<Plan, ChecklistTask>
typealias MultiPlanTaskPayload = TaskPayload<Plan, [ChecklistTask]>
typealias SingleChecklistTaskPayload = TaskPayload<Checklist, ChecklistTask>
typealias MultiChecklistTaskPayload = TaskPayload<Checklist, [ChecklistTask]>
