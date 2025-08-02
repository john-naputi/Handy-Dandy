//
//  Handlers.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import Foundation
import SwiftData

struct TaskActionDelegate {
    var onEditDone: ((ChecklistTask) -> Void)?
    var onAddDone: ((ChecklistTask) -> Void)?
    var onCancel: (() -> Void)?
}

struct ViewableTaskActionDelegate {
    var onBeginEdit: ((ChecklistTask) -> Void)?
    var onTaskComplete: ((ChecklistTask) -> Void)?
    var onBeginAdd: (() -> Void)?
    var onDelete: ((IndexSet) -> Void)?
}
