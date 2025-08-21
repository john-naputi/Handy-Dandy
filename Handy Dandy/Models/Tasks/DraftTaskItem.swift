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
    
    init(from shadow: GeneralTaskShadow) {
        self.id = shadow.id
        self.text = shadow.text
        self.isDone = shadow.isDone
    }
    
    init?(from item: TaskListItemShadow) {
        switch item.payload {
        case .general(let general):
            self.init(from: general)
        case .shopping(let shopping):
            return nil
        }
    }
}
