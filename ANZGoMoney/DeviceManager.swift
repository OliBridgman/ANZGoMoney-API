//
//  DeviceManager.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import KeychainAccess

struct DeviceToken {
    let deviceToken: String
    let key: String
    let passcode: String
    
    init(deviceToken: String, key: String, passcode: String) {
        self.deviceToken = deviceToken
        self.key = key
        self.passcode = passcode
    }
}

public class DeviceManager {
    
    private let keychain = Keychain(service: "com.uo.gomoney.device-token")
    
    private struct Shared {
        static var instance = DeviceManager()
    }
    
    public static var sharedInstance: DeviceManager {
        get {
            return Shared.instance
        }
        set (newSharedProvider) {
            Shared.instance = newSharedProvider
        }
    }
    
    func retrieveDeviceToken() -> DeviceToken? {
        
        do {
            if  let deviceToken = try self.keychain.get("deviceToken"),
                let key = try self.keychain.get("key"),
                let passcode = try self.keychain.get("passcode") {
                    
                   return DeviceToken(deviceToken: deviceToken, key: key, passcode: passcode)
            }

        } catch {
            return nil
        }
        return nil
    }
    
    func storeDeviceToken(deviceToken: DeviceToken) {
        
        self.keychain["deviceToken"] = deviceToken.deviceToken
        self.keychain["key"] = deviceToken.key
        self.keychain["passcode"] = deviceToken.passcode
    }
}
