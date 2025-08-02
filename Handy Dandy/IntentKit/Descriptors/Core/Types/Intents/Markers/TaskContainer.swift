//
//  TaskContainer.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftData

protocol TaskContainer: Observable, AnyObject {
    var tasks: [ChecklistTask] { get set }
    func name() -> String
    func description() -> String
    func addTask(_ task: ChecklistTask)
    func removeTask(_ task: ChecklistTask)
}
