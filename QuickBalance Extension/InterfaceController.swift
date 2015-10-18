//
//  InterfaceController.swift
//  QuickBalance Extension
//
//  Created by Will Townsend on 15/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import WatchKit
import Foundation
import ReactiveCocoa

import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    let api = ANZGoMoneyAPI()
    var accounts = [Account]()
    
    private let session : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
        
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var textLabel: WKInterfaceLabel!
    
    @IBAction func touchedRefresh() {
        test()
    }
    
    func test() {
        
        print(self.session)
        
        print(DeviceManager.sharedInstance.keychain)
        
        if let deviceToken = DeviceManager.sharedInstance.retrieveDeviceToken() {
            print("Signed in, well, have a token")
            self.textLabel.setText("signed in")
            
            NSLog("networking..")
            
            self.api.authenticatedFetchAccountsSignal(deviceToken.deviceToken, pin2: deviceToken.passcode).observeOn(UIScheduler()).startWithNext { accounts in
                
                NSLog("%@", accounts)
                
                self.accounts = accounts
                
                let account = accounts.filter { $0.nickname == "MAIN" }
                
                if let account = account.first {
                    self.textLabel.setText("MAIN: $\(account.balance)")
                } else {
                    self.textLabel.setText("failed")
                }
                
            }
            
        } else {
            
            self.textLabel.setText("not :( signed in")
            
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.session?.delegate = self
        self.session?.activateSession()
        // Configure interface objects here.
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        test()
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK - WCSessionDelegate
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        
        print("receieved userInfo!")
        
        if let deviceToken = userInfo["token"] as? String, passcode = userInfo["passcode"] as? String, key = userInfo["key"] as? String {
            
            
            
            let deviceToken = DeviceToken(deviceToken: deviceToken, key: key, passcode: passcode)
            DeviceManager.sharedInstance.storeDeviceToken(deviceToken)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.test()
            })
        }
        
    }

}
