//
//  HandyDandyUITests.swift
//  HandyDandyUITests
//
//  Created by John Naputi on 8/2/25.
//

import XCTest

final class HandyDandyUITests: XCTestCase {
    let app = XCUIApplication()
    
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        app.launch()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testCreatePlanFlow() throws {
        let createButton = app.buttons["ViewablePlansList_CreateButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 2))
        createButton.tap()
        
        let titleField = app.textFields["EditablePlan_NameTextField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Rover")
        
        let descriptionField = app.textFields["EditablePlan_DescriptionTextField"]
        XCTAssertTrue(descriptionField.waitForExistence(timeout: 2))
        descriptionField.tap()
        descriptionField.typeText("Gopher")
        
        let dateField = app.datePickers["EditablePlan_DatePicker"]
        XCTAssertTrue(dateField.waitForExistence(timeout: 2))
        dateField.tap()
        let dateToSelect = app.collectionViews.buttons["15"]
        dateToSelect.tap()
        XCTAssertTrue(dateToSelect.waitForExistence(timeout: 2))
        
        
        let saveButton = app.buttons["EditablePlan_ConfirmButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()
        
        let nameTextField = app.textFields["ViewablePlansList_Title"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 2))
        XCTAssertEqual(nameTextField.label, "Rover")
        
        let descriptionTextField = app.textFields["ViewablePlansList_Description"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 2))
        XCTAssertEqual(nameTextField.label, "Gopher")
    }
}
