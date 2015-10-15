//
//  ANZGoMoneyAPI+Signals.swift
//  ANZGoMoney
//
//  Created by Will Townsend on 11/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SwiftyJSON

public class Account: NSObject, NSCoding {
    
    let key: String
    let customerKey: String
    let nickname: String
    let balance: String
    let available: String
    let productName: String
    
    init(key: String, customerKey: String, nickname: String, balance: String, available: String, productName: String) {
        
        self.key = key
        self.customerKey = customerKey
        self.nickname = nickname
        self.balance = balance
        self.available = available
        self.productName = productName
        
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {

        self.key = aDecoder.decodeObjectForKey("key") as! String
        self.customerKey = aDecoder.decodeObjectForKey("customerKey") as! String
        self.nickname = aDecoder.decodeObjectForKey("nickname") as! String
        self.balance = aDecoder.decodeObjectForKey("balance") as! String
        self.available = aDecoder.decodeObjectForKey("available") as! String
        self.productName = aDecoder.decodeObjectForKey("productName") as! String
        
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.key, forKey: "key")
        aCoder.encodeObject(self.customerKey, forKey: "customerKey")
        aCoder.encodeObject(self.nickname, forKey: "nickname")
        aCoder.encodeObject(self.balance, forKey: "balance")
        aCoder.encodeObject(self.available, forKey: "available")
        aCoder.encodeObject(self.productName, forKey: "productName")
    }
    
}

extension ANZGoMoneyAPI {
    
    // Really really hacky.
    public func authenticatedFetchAccountsSignal(deviceToken: String, pin2: String) -> SignalProducer<[Account], APIError> {
        return self.fetchAccountsSignal()
            .flatMapError { (error: APIError) -> SignalProducer<[Account], APIError> in
                return self.authenticate(deviceToken, pin2: pin2)
                    .flatMap(.Latest) { responseData in
                        return self.fetchAccountsSignal()
                    }
            }
    }
    
    public func fetchAccountsSignal() -> SignalProducer<[Account], APIError> {
       
        return SignalProducer<[Account], APIError> { observer, disposable in
            
//            NSUserDefaults.standardUserDefaults().removeObjectForKey("accounts")
            
            if let savedAccounts = NSUserDefaults.standardUserDefaults().dataForKey("accounts"){
                print(savedAccounts)
                if let accounts = NSKeyedUnarchiver.unarchiveObjectWithData(savedAccounts) as? [Account] {
                    print(accounts)
                    sendNext(observer, accounts)
                }
            }
            
            self.fetchAccounts({ (response) -> () in
                
                switch (response) {
                case .Failed(let error, let responseObject):
                    print(error)
                    print(responseObject)
                    sendError(observer, APIError.Unknown)
                    
                case .Success(let responseObject):
                    
                    let json = JSON(responseObject)
                    
                    let accounts = json["accounts"].arrayValue
                    
                    let transformed = accounts.map({ account in
                        
                        return Account(key: account["key"].stringValue,
                            customerKey: account["customerKey"].stringValue,
                            nickname: account["nickname"].stringValue,
                            balance: account["balance"].stringValue,
                            available: account["available"].stringValue,
                            productName: account["productName"].stringValue
                        )
                    })
                    
                    let accountsData = NSKeyedArchiver.archivedDataWithRootObject(transformed)
                    NSUserDefaults.standardUserDefaults().setObject(accountsData, forKey: "accounts")
                    
                    sendNext(observer, transformed)
                    sendCompleted(observer)
                    
                }
            })
        }
    }
    
    public func authenticate(deviceToken: String, pin2: String) -> SignalProducer<AnyObject, APIError> {
    
        return SignalProducer<AnyObject, APIError> { observer, disposable in
            self.authenticate(deviceToken, pin: pin2, completion: { (response) -> () in
                switch (response) {
                case .Failed(let error, _):
                    print(error)
                    sendError(observer, APIError.LoginDenied)
                case .Success(let responseObject):
                    sendNext(observer, responseObject)
                    sendCompleted(observer)
                }
            })
        }
    }
    
}