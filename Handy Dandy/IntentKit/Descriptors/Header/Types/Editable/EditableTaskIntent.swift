//
//  EditableTaskIntent.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/31/25.
//

struct EditableTaskIntent : EditableIntent, TaskIntent {
    var data: Task
    var mode: EditMode
    var delegate: TaskActionDelegate
}
