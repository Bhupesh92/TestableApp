//
//  MockNetworkService.swift
//  TestableAppTests
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
class MockNetworkService: NetworkService {
    func login(email: String, password: String,
               completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("mock_token"))
    }
}
