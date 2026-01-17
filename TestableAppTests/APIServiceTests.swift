//
//  APIServiceTests.swift
//  TestableAppTests
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
import XCTest

final class APIServiceTests: XCTestCase {
    
    func testLoginReturnsToken() {
        let service = APIService()
        let expectation = expectation(description: "API Login")
        
        service.login(email: "test@mail.com", password: "123456") { result in
            XCTAssertNotNil(try? result.get())
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}
