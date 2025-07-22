//
//  Handy_DandyApp.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/20/25.
//

import SwiftUI
import SwiftData

@main
struct Handy_DandyApp: App {

    var body: some Scene {
        WindowGroup {
            PlansListView()
        }
        .modelContainer(for: [Plan.self, Checklist.self, Task.self])
    }
}
