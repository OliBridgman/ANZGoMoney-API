//
//  PasscodeViewModel.swift
//  ANZGoMoney
//
//  Created by Will Townsend on 11/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SwiftyJSON

class PasscodeViewModel: ViewModel {
    
    
    let services: Services
    
    let title = MutableProperty<String?>("Enter Passcode")
    
    let passcode = MutableProperty<String?>("")
    
    let data = MutableProperty<JSONDictionary?>(nil)
    
    required init(services: Services) {
        
        self.services = services
        
        
        let createPasscodeAction = Action<String, DeviceToken, NoError> { value in
            
            return SignalProducer<DeviceToken, NoError> { observer, disposable in
                
                self.services.api.verifyPin(self.passcode.value!, deviceDescription: "iphone", completion: { (response) -> () in
                    
                    switch (response) {
                    case .Failed(let error, let _):
                        print(error)
//                        print(responseObject)
                        //                    sendError(observer, LoginViewModelError.Unknown)
                    case .Success(let responseObject):
                        
                        let json = JSON(responseObject)
                        
                        if let deviceToken = json["newDevice"]["deviceToken"].string, let key = json["newDevice"]["key"].string, passcode = self.passcode.value {
                            
                            let deviceToken = DeviceToken(deviceToken: deviceToken, key: key, passcode: passcode)

//                            self.sendWatchDeviceToken(deviceToken)

                            DeviceManager.sharedInstance.storeDeviceToken(deviceToken)
                            print(deviceToken)
                            sendNext(observer, deviceToken)
                            
                        } else {
                            print("Failed to find the device token")
                        }
                    }
                })
            }
        }
        
        self.passcode.producer
            .filter { $0?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 4 }
            .startWithNext { next in
                print("Entered 4 characters: \(next)")
                
                createPasscodeAction.apply(next!).observeOn(UIScheduler()).startWithNext { next in
                    
                    // transition
                    let accountViewModel = AccountsViewModel(services: self.services)
                    self.services.router.resetToRootViewModel(accountViewModel)
                    
                }
        }
    }

    
}