//
//  ViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 24/08/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import UIKit
import ANZGoMoneyAPI
import KeychainAccess

class ViewController: UIViewController {
    
    let keychain = Keychain(service: "com.uo.anzgomoney")
    
    var oneTimePassword: String = ""
    var ibSessionId: String = ""
    
    let api = ANZGoMoneyAPI()
    
    @IBAction func createPinTouched(sender: AnyObject) {
        
        api.verifyPin(Private.passcode, deviceDescription: "[iPhone5,2]") { (response) -> () in
            
            // Parse the deviceToken + Key
            
            
            print(response)
        }
        
    }
    
    @IBAction func fetchAccountButtonTouched(sender: AnyObject) {
        
        api.fetchAccounts { (response) -> () in
            print(response)
        }
        
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var authCodeTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    // MARK: - Actions
    
    @IBAction func touchedButton(sender: AnyObject) {
        
        
        api.authenticate(usernameTextField.text!, password: passwordTextField.text!) { (response) -> () in
            
            switch (response) {
            case .Failed(let error, _):
                
                switch error {
                case .AuthCodeSent(let oneTimePassword):
                    self.oneTimePassword = oneTimePassword
                    print("One Time password retrieved")
                default:
                    return;
                }
                
            case .Success(let responseObject):
                print(responseObject)
            }
            
        }
        
    }
    
    @IBAction func touchedOneTimeCode(sender: AnyObject) {
        
        api.authenticate(self.usernameTextField.text!, oneTimePassword: self.oneTimePassword, authCode: self.authCodeTextField.text!)  { (response) -> () in
            
            switch (response) {
            case .Failed(let error, let responseObject):
                print(error)
                print(responseObject)
            case .Success(let responseObject):
//                print(responseObject)
                
                if let sessionId = responseObject["ibSessionId"] {
                    print("FOUND sessionId \(sessionId)")
                    self.ibSessionId = sessionId as! String
                    self.api.ibSessionId = self.ibSessionId
                }
                
            }
            
        }
        
    }
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.text = Private.username
        self.passwordTextField.text = Private.password
        
    }
    
}
