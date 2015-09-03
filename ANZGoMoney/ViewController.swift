//
//  ViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 24/08/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import UIKit
import ANZGoMoneyAPI

class ViewController: UIViewController {
    
    var oneTimePassword: String = ""
    
    @IBAction func createPinTouched(sender: AnyObject) {
        
        let api = ANZGoMoneyAPI()
        
        api.createPin("3320", deviceToken: "4ec2b98f-62ab-40ab-bb3e-d4ca88c1507e") { (response) -> () in
            print(response)
        }
        
//        api.verifyPin("1234", deviceDescription: "test device") { (response) -> () in
//            print(response)
//        }
        
    }
    
    @IBAction func fetchAccountButtonTouched(sender: AnyObject) {
        
        let api = ANZGoMoneyAPI()
        
        api.fetchAccounts { (response) -> () in
            print(response)
        }
        
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var authCodeTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    // MARK: - Actions
    
    @IBAction func touchedButton(sender: AnyObject) {
        
        let api = ANZGoMoneyAPI()
        
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
        
        let api = ANZGoMoneyAPI()
        api.authenticate(self.usernameTextField.text!, oneTimePassword: self.oneTimePassword, authCode: self.authCodeTextField.text!)  { (response) -> () in
            
            switch (response) {
            case .Failed(let error, let responseObject):
                print(error)
                print(responseObject)
            case .Success(let responseObject):
                print(responseObject)
            }
            
        }
        
    }
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
