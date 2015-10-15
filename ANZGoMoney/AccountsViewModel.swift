//
//  AccountsViewModel.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa

typealias JSONDictionary = Dictionary<String, AnyObject>

class AccountsViewModel: ViewModel {
    
    let services: Services
    
    let title = MutableProperty<String?>("Your Accounts")
    
    var logoutAction: CocoaAction?
    
    let data = MutableProperty<[Account]>([Account]())
    
    required init(services: Services) {
        
        self.services = services
        
        let logInActionBlock = Action<Void, String, NoError> {
            
            let loginViewModel = LoginViewModel(services: self.services)
            self.services.router.resetToRootViewModel(loginViewModel)
            
            return SignalProducer.empty
        }
        
        self.logoutAction = CocoaAction(logInActionBlock) { _ in print("logout button tapped") }
        
        self.data <~ self.fetchAccounts()
        
    }
    
    func fetchAccounts() -> SignalProducer<[Account], NoError> {
        
        guard let deviceToken = DeviceManager.sharedInstance.retrieveDeviceToken() else {
            return SignalProducer.empty
        }
        
        return self.services.api.authenticatedFetchAccountsSignal(deviceToken.deviceToken, pin2: deviceToken.passcode)
            .flatMapError { error in
                return SignalProducer.empty
        }
        
//        let test = self.services.api.authenticate(deviceToken.deviceToken, pin2:deviceToken.passcode)
//        .flatMap(FlattenStrategy.Concat, transform: { value in
//            return self.services.api.fetchAccountsSignal()
//        })
//        
//        
    
//        return self.services.api.fetchAccounts()
    }
}
