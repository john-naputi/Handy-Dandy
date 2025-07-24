//
//  Handlers.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import Foundation
import SwiftData

struct TaskActionDelegate {
    var onEditDone: ((Task) -> Void)?
    var onAddDone: ((Task) -> Void)?
    var onCancel: (() -> Void)?
}

struct ViewableTaskActionDelegate {
    var onBeginEdit: ((Task) -> Void)?
    var onTaskComplete: ((Task) -> Void)?
    var onBeginAdd: (() -> Void)?
    var onDelete: ((IndexSet) -> Void)?
}
