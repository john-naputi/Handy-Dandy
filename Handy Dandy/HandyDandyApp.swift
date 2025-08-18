//
//  Handy_DandyApp.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import SwiftUI
import SwiftData

@main
struct HandyDandyApp: App {
    var body: some Scene {
        WindowGroup {
            HandyDandyEntrypoint()
        }
        .modelContainer(for: [Plan.self, Checklist.self, ChecklistTask.self, TaskList.self, TaskItem.self, ShoppingList.self])
    }
}
