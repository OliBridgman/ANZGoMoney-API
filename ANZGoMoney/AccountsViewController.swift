//
//  AccountsViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation

import UIKit
import ReactiveCocoa

class AccountsViewController: UIViewController, ViewModelViewController {
    
    let viewModel: AccountsViewModel
    
    required init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AccountsViewController", bundle: nil)
        self.title = viewModel.title.value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Actions
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Done, target: self.viewModel.logoutAction, action: CocoaAction.selector)
        
//        // Have to manually add the contraint to the topLayoutGuide. >.<
//        let topLayoutGuide = NSLayoutConstraint(
//            item: self.usernameTextField,
//            attribute: .Top,
//            relatedBy: .Equal,
//            toItem: self.topLayoutGuide,
//            attribute: .Bottom,
//            multiplier: 1.0,
//            constant: 10
//        )
//        self.view.addConstraint(topLayoutGuide)
        
    }
}