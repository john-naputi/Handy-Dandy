//
//  DraftTask.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/23/25.
//

import Foundation

struct DraftTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var showDescription: Bool = false
    
    init(title: String, description: String, showDescription: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.showDescription = showDescription
    }
}
