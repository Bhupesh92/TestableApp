//
//  LoginViewModelTests.swift
//  TestableAppTests
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
import XCTest

final class LoginViewModelTests: XCTestCase {
    
    var viewModel: LoginViewModel!
    
    override func setUp() {
        viewModel = LoginViewModel(service: MockNetworkService())
    }
    
    func testEmailPasswordValidation() {
        XCTAssertTrue(viewModel.validate(email: "a@b.com", password: "123456"))
        XCTAssertFalse(viewModel.validate(email: "abc", password: "123"))
    }
    
    func testLoginSuccess() {
        let expectation = expectation(description: "Login Success")
        
        viewModel.login(email: "a@b.com", password: "123456") { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
