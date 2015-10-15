//
//  InterfaceController.swift
//  QuickBalance Extension
//
//  Created by Will Townsend on 15/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var textLabel: WKInterfaceLabel!
    
    @IBAction func touchedRefresh() {
        test()
    }
    
    func test() {
        
        print(DeviceManager.sharedInstance.keychain)
        
        if let deviceToken = DeviceManager.sharedInstance.retrieveDeviceToken() {
            print("Signed in, well, have a token")
            self.textLabel.setText("signed in")
            
        } else {
            
            self.textLabel.setText("not :( signed in")
            
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        

        
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

}
