//
//  TaskIntegrationTest.swift
//  Handy DandyTests
//
//  Created by John Naputi on 8/2/25.
//

import XCTest
import SwiftData
@testable import Handy_Dandy

final class TaskIntegrationTest : XCTestCase {
    var modelContainer: ModelContainer!
    var context: ModelContext!
    
    @MainActor
    override func setUpWithError() throws {
        modelContainer = try ModelContainer(for: Plan.self, Checklist.self, Task.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = modelContainer.mainContext
    }
    
    @MainActor
    func testAddingTaskToChecklist() throws {
        let plan = Plan(title: "Test Plan", description: "The Best Plan")
        context.insert(plan)
        
        let checklist = Checklist(title: "Checklist", checklistDescription: "The Checklist")
        context.insert(checklist)
        
        let task = Task(title: "Buy eggs", description: "Organic if possible")
        checklist.tasks.append(task)
        plan.checklists.append(checklist)
        context.insert(task)
        
        try context.save()
        
        let fetched = try context.fetch(FetchDescriptor<Checklist>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].tasks.count, 1)
        XCTAssertEqual(fetched[0].tasks[0].title, "Buy eggs")
    }
}
