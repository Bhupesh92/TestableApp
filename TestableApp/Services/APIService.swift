//
//  APIService.swift
//  TestableApp
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
class APIService: NetworkService {
    func login(email: String, password: String,
               completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(.success("token_123"))
        }
    }
}
