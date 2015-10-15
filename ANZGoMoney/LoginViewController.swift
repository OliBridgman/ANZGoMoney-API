//
//  LoginViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

class LoginViewController: UIViewController, ViewModelViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let viewModel: LoginViewModel
    
    required init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoginViewController", bundle: nil)
        self.title = viewModel.title.value
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Have to manually add the contraint to the topLayoutGuide. >.<
        let topLayoutGuide = NSLayoutConstraint(
            item: self.usernameTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 10
        )
        self.view.addConstraint(topLayoutGuide)
        
        // Set initial values from the viewModel
        self.usernameTextField.text = self.viewModel.username.value
        self.passwordTextField.text = self.viewModel.password.value
        
        // Create the bindings
        self.rac_title <~ self.viewModel.title
        self.viewModel.username <~ self.usernameTextField.rac_text
        self.viewModel.password <~ self.passwordTextField.rac_text
        self.loginButton.rac_enabled <~ self.viewModel.isValid.producer.observeOn(UIScheduler())
        
        // Add Actionsa
        self.loginButton.addTarget(self.viewModel.loginAction!, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
        
        // Disabled the button when the action is running
        self.loginButton.rac_enabled <~ self.viewModel.loginActionBlock!.enabled.producer.observeOn(UIScheduler())
        
        self.viewModel.loginActionBlock!.errors.observeOn(UIScheduler()).observe({ error in
            
            guard let apiError = error.value else {
                print("no error")
                return
            }
            
            switch apiError {
            case .OneTimePasswordRequired(let oneTimePassword):
                
                let alertController = UIAlertController(title: "2 Factor Auth", message: "Please enter the auth code you will have recieved via sms", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addTextFieldWithConfigurationHandler({ (let textField) -> Void in
                    textField.returnKeyType = .Go
                    textField.placeholder = "auth code"
                    textField.secureTextEntry = true
                })
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (let action) -> Void in
                    print("cancelled")
                }))
                
                alertController.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { (let action) -> Void in
                    
                    let authCode = alertController.textFields?.first?.text
                    let otp = oneTimePassword
                    
                    if let authCode = authCode {
                        let twoFactorInfo = (oneTimePassword: otp, authCode: authCode)
                        self.viewModel.loginActionBlock?.apply(twoFactorInfo).start()
                    }
                    
                    print("loggin in with \(authCode), \(otp)")
                    
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                                
            case .Unknown:
                let alertController = UIAlertController(title: "Error!", message: "There was an error", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { (let action) -> Void in
                    print("okay")
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        })
    }
}
