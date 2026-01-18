//
//  XCTestExtension.swift
//  TestableApp
//
//  Created by Kumari Bhavana on 18/01/26.
//

import Foundation
import XCTest

extension XCTestCase {

    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Potential memory leak. Object should have been deallocated.",
                file: file,
                line: line
            )
        }
    }
}
