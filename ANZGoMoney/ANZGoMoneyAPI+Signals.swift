//
//  ANZGoMoneyAPI+Signals.swift
//  ANZGoMoney
//
//  Created by Will Townsend on 11/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ANZGoMoneyAPI
import ReactiveCocoa
import SwiftyJSON

public class Account {
    
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
        
    }
    
}

extension ANZGoMoneyAPI {
    
    public func fetchAccounts2() -> SignalProducer<[Account], NoError> {
        
        return SignalProducer<[Account], NoError> { observer, disposable in
            
            self.fetchAccounts({ (response) -> () in
                
                switch (response) {
                case .Failed(let error, let responseObject):
                    print(error)
                    print(responseObject)
                    //                    sendError(observer, LoginViewModelError.Unknown)
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
                    
                    sendNext(observer, transformed)
                    sendCompleted(observer)
                    
                }
            })
        }
    }
    
    public func authenticate(deviceToken: String, pin2: String) -> SignalProducer<AnyObject, NoError> {
    
        return SignalProducer<AnyObject, NoError> { observer, disposable in
            
            self.authenticate(deviceToken, pin: pin2, completion: { (response) -> () in
                sendNext(observer, "okay")
                sendCompleted(observer)
            })
        }
    }
    
}