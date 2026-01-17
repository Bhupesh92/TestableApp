//
//  LoginFlowUITests.swift
//  TestableAppUITests
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
import XCTest

final class LoginFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITEST_MODE"]
        app.launch()
        
        if ProcessInfo.processInfo.arguments.contains("UITEST_MODE") {
            UIView.setAnimationsEnabled(false)
        }
    }
    
    func testLoginFlowSuccess() {
        let loginPage = LoginPage(app: app)
        loginPage.login(email: "test@mail.com", password: "123456")
        
        XCTAssertTrue(app.staticTexts["home_title"].waitForExistence(timeout: 3))
    }
}
