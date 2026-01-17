//
//  ViewController.swift
//  TestableApp
//
//  Created by Kumari Bhavana on 17/01/26.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var loginHandler: LoginHandlerProtocol? = LoginViewModel()
    
    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func loginAction(_ sender: UIButton) {
        let email = emailTf.text ?? ""
        let password = passwordTf.text ?? ""
        loginHandler?.login(email: email, password: password) { success in
            if success {
                print("Login Successful")
                
                func navigateToHome() {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                        self.present(vc, animated: true)
                    }
                }
                navigateToHome()
            } else {
                print("Login Failed")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

