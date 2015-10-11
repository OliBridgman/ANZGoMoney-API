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

class AccountsViewController: UIViewController, ViewModelViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self
        
        // Add Actions
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Done, target: self.viewModel.logoutAction, action: CocoaAction.selector)
        
        self.viewModel.data.producer.observeOn(UIScheduler()).startWithNext { next in
            print("RECIEVED ACCOUNTTSS@!!! \(next)")
            self.tableView.reloadData()
        }
        
    }
    
    // UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.data.value.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let account = self.viewModel.data.value[indexPath.row]
        
        cell.textLabel?.text = account.nickname
        
        if let balance = Double(account.balance) {
            cell.detailTextLabel?.text = "\(balance * Double(arc4random_uniform(150)/150))"
        }
        
        
        
        return cell
    }
    
}