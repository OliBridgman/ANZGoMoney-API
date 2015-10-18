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
import WatchConnectivity

class AccountsViewController: UIViewController, ViewModelViewController, UITableViewDataSource, WCSessionDelegate {
    
    let watchConnectivitySession: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
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
        
        self.watchConnectivitySession?.delegate = self
        self.watchConnectivitySession?.activateSession()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self
        
        // Add Actions
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Done, target: self.viewModel.logoutAction, action: CocoaAction.selector)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Done, target: self, action: Selector("sendWatchData"))
        
        self.viewModel.data.producer.observeOn(UIScheduler()).startWithNext { next in
            self.tableView.reloadData()
        }
        
    }
    
    func sendWatchData() {
        
        print(self.watchConnectivitySession)
        
        if let deviceToken = DeviceManager.sharedInstance.retrieveDeviceToken() {
            
            let userInfo = ["token": deviceToken.deviceToken, "key": deviceToken.key, "passcode": deviceToken.passcode] as [String: AnyObject]
            self.watchConnectivitySession?.transferUserInfo(userInfo)
            
        } else {
            print("no token")
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
            cell.textLabel?.text = "\(account.nickname) $\(balance)"
        }
        
        
        return cell
    }
    
    // MARK - WCSessionDelegate
    
    
    func sessionReachabilityDidChange(session: WCSession) {
        print(session)
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        print(session)
    }
    
    
}

