//
//  DeviceManager.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import KeychainAccess

public struct DeviceToken {
    let deviceToken: String
    let key: String
    let passcode: String
    
    public init(deviceToken: String, key: String, passcode: String) {
        self.deviceToken = deviceToken
        self.key = key
        self.passcode = passcode
    }
}

public class DeviceManager {
    
    public let keychain = Keychain(service: "com.uo.gomoney.device-token", accessGroup: "DQA7HX6GV3.com.wtsnz.ANZGoMoney.shared").accessibility(.AfterFirstUnlock)

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
        
        /* Obtaining all stored keys */
        let keys = keychain.allKeys()
        for key in keys {
            print("key: \(key)")
        }
        
        /* Obtaining all stored items */
        let items = keychain.allItems()
        for item in items {
            print("item: \(item)")
        }
        
        do {
            if  let deviceToken = try self.keychain.get("deviceToken"),
                let key = try self.keychain.get("key"),
                let passcode = try self.keychain.get("passcode") {
                    
                   return DeviceToken(deviceToken: deviceToken, key: key, passcode: passcode)
            }

        } catch let error {
            print(error)
            return nil
        }
        return nil
    }
    
    func storeDeviceToken(deviceToken: DeviceToken) {
        
        self.keychain["deviceToken"] = deviceToken.deviceToken
        self.keychain["key"] = deviceToken.key
        self.keychain["passcode"] = deviceToken.passcode
    }
    
    func removeDeviceToken() {
        self.keychain["deviceToken"] = nil
        self.keychain["key"] = nil
        self.keychain["passcode"] = nil
    }
    
}
