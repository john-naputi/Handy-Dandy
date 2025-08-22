//
//  SingleTaskShadow.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/20/25.
//

import Foundation

struct SingleTaskShadow: Equatable, Identifiable {
    let id: UUID
    let title: String
    let isDone: Bool
    
    var progress: Double {
        isDone ? 1 : 0
    }
    
    var progressText: String {
        isDone ? "Completed" : "Not completed"
    }
    
    var progressPercentText: String {
        isDone ? "100% done" : "0% done"
    }
    
    init (id: UUID = UUID(), title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
    
    init(from model: SingleTask) {
        self.id = model.uid
        self.title = model.title
        self.isDone = model.isDone
    }
    
    func toggled() -> SingleTaskShadow {
        .init(id: id, title: title, isDone: !isDone)
    }
    
    func rename(to newTitle: String) -> SingleTaskShadow {
        .init(id: id, title: newTitle, isDone: isDone)
    }
}
