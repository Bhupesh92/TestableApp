//
//  LoginPage.swift
//  TestableAppUITests
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
import XCTest

class LoginPage {
    let app: XCUIApplication
    init(app: XCUIApplication) { self.app = app }
    
    var email: XCUIElement { app.textFields["email_field"] }
    var password: XCUIElement { app.textFields["password_field"] }
    var loginButton: XCUIElement { app.buttons["login_button"] }
    
    func login(email: String, password: String) {
        self.email.tap()
        self.email.typeText(email)
        self.password.tap()
        self.password.typeText(password)
        loginButton.tap()
    }
}
