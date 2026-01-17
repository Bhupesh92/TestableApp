//
//  HomePage.swift
//  TestableAppUITests
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
import XCTest

class HomePage {
    let app: XCUIApplication
    init(app: XCUIApplication) { self.app = app }
    
    var hometext: XCUIElement { app.buttons["home_title"] }
}
