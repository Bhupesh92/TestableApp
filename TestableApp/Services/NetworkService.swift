//
//  NetworkService.swift
//  TestableApp
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation
protocol NetworkService {
    func login(email: String, password: String,
               completion: @escaping (Result<String, Error>) -> Void)
}
