//
//  AccountsViewModel.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa

class AccountsViewModel: ViewModel {
    
    let services: Services
    
    let title = MutableProperty<String?>("Your Accounts")
    
    var logoutAction: CocoaAction?
    
    required init(services: Services) {
        
        self.services = services
        
        let logInActionBlock = Action<Void, String, NoError> {
            
            let loginViewModel = LoginViewModel(services: self.services)
            self.services.router.resetToRootViewModel(loginViewModel)
            
            return SignalProducer.empty
        }
        
        self.logoutAction = CocoaAction(logInActionBlock) { _ in print("logout button tapped") }
        
    }
}
