//
//  EditableExperienceTest.swift
//  HandyDandy.UITests
//
//  Created by John Naputi on 8/12/25.
//

import XCTest

@MainActor
final class EditableExperienceDescriptorUITest: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["UI_TESTING", "SEED_EMPTY"]
        app.launch()
    }
    
    func test_createUserExperience() {
        app.buttons["AddExperienceButton"].tap()
        
        let titleField = app.textFields["Editable_ExperienceTitle"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        XCTAssertEqual(titleField.value as? String, "")
        
        // Submit button should be disabled initially
        let submitButton = app.buttons["Editable_ExperienceConfirmButton"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 2))
        XCTAssertTrue(!submitButton.isEnabled)
        
        // Type in a title
        titleField.tap()
        titleField.typeText("My New Experience2")
        
        // Tap save
        submitButton.tap()
        
        let newRow = app.staticTexts["My New Experience3"]
        XCTAssertTrue(newRow.waitForExistence(timeout: 2))
    }
}
