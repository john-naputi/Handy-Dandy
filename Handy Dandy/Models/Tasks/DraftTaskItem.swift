//
//  DraftTask.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/23/25.
//

import Foundation

struct DraftTaskItem: Identifiable, Equatable {
    var id: UUID
    var text: String
    var isDone: Bool
    
    init(id: UUID, text: String, isDone: Bool) {
        self.id = id
        self.text = text
        self.isDone = isDone
    }
    
    init(from shadow: TaskItemShadow) {
        self.id = shadow.id
        self.text = shadow.text
        self.isDone = shadow.isDone
    }
}
