//
//  LoginViewModel.swift
//  TestableApp
//
//  Created by Kumari Bhavana on 17/01/26.
//

import Foundation

protocol LoginHandlerProtocol {
    func login(email: String, password: String,
               completion: @escaping (Bool) -> Void)
}

class LoginViewModel: LoginHandlerProtocol {
    
    var service: NetworkService?
    
    init(service: NetworkService) {
        self.service = service
    }
    
    convenience init() {
        self.init(service: APIService())
    }
    
    func validate(email: String, password: String) -> Bool {
        return email.contains("@") && password.count >= 6
    }
    
    func login(email: String, password: String,
               completion: @escaping (Bool) -> Void) {
        service?.login(email: email, password: password) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}
