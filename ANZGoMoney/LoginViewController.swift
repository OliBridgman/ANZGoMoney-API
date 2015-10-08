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
        
        // Add Actions
        self.loginButton.addTarget(self.viewModel.loginAction, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
        
    }
}
