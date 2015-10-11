//
//  PasscodeViewController.swift
//  ANZGoMoney
//
//  Created by Will Townsend on 11/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation

import UIKit
import ReactiveCocoa

class PasscodeViewController: UIViewController, ViewModelViewController {
    
    @IBOutlet weak var passcodeTextField: UITextField!
    
    let viewModel: PasscodeViewModel
    
    required init(viewModel: PasscodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PasscodeViewController", bundle: nil)
        self.title = viewModel.title.value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.passcode <~ self.passcodeTextField.rac_text
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.passcodeTextField.becomeFirstResponder()
        super.viewWillAppear(animated)
    }
    
}