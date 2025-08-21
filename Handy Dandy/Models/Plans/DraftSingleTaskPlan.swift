//
//  DraftSingleTaskPlan.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/21/25.
//

import Foundation

struct DraftSingleTaskPlan: Identifiable {
    var id: UUID
    var title: String
    var isDone: Bool
    
    init(id: UUID = UUID(), title: String = "", isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}
