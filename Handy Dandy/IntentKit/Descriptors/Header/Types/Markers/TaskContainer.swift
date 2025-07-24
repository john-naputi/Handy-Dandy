//
//  TaskContainer.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/1/25.
//

import SwiftData

protocol TaskContainer: Observable, AnyObject {
    var tasks: [Task] { get set }
    func name() -> String
    func description() -> String
    func addTask(_ task: Task)
    func removeTask(_ task: Task)
}
