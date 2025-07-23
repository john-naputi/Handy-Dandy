//
//  TaskDraft.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/22/25.
//

import Foundation

struct TaskDraft: Identifiable, Equatable {
    let id: UUID = UUID()
    var title: String = ""
    var description: String = ""
    var showDescription: Bool = false
}
