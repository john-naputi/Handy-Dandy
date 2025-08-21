//
//  SingleTaskShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import Foundation

struct SingleTaskShadow: Equatable {
    let id: UUID
    let title: String
    let isDone: Bool
    let item: TaskListItemShadow
    
    init(id: UUID = UUID(), title: String = "", isDone: Bool = false, item: TaskListItemShadow) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.item = item
    }
}
