//
//  DraftTaskList.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/18/25.
//

import Foundation

struct DraftTaskList: Identifiable {
    let id: UUID
    var title: String
    var items: [DraftTaskItem]
    
    init(id: UUID = .init(), title: String = "", items: [DraftTaskItem] = []) {
        self.id = id
        self.title = title
        self.items = items
    }
    
    init(from shadow: TaskListShadow) {
        self.id = shadow.id
        self.title = shadow.title
        self.items = shadow.tasks.compactMap(DraftTaskItem.init(from:))
    }
}
