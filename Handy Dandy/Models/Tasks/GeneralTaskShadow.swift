//
//  TaskItemShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation

struct GeneralTaskShadow: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isDone: Bool
    
    init(id: UUID, text: String, isDone: Bool) {
        self.id = id
        self.text = text
        self.isDone = isDone
    }
    
    init(from model: TaskItem) {
        self.id = model.taskItemId
        self.text = model.text
        self.isDone = model.isDone
    }
    
    func toggle() -> GeneralTaskShadow {
        GeneralTaskShadow(id: id, text: text, isDone: !isDone)
    }
}
