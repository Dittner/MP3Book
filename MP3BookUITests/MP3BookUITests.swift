//
//  MP3BookUITests.swift
//  MP3BookUITests
//
//  Created by Alexander Dittner on 01.02.2021.
//

import XCTest

class MP3BookUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        // UI tests are very expensive to run. It is a good idea to stop it when the tests fail
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("01BookList", waitForLoadingIndicator: true)

        app/*@START_MENU_TOKEN@*/ .staticTexts["addBooks"]/*[[".staticTexts[\"\"]",".staticTexts[\"addBooks\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ .tap()

        snapshot("03Library", waitForLoadingIndicator: true)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
