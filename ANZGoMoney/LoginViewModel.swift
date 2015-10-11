//
//  LoginViewModel.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ANZGoMoneyAPI

enum LoginViewModelError: ErrorType {
    case OneTimePasswordRequired(oneTimePassword: String)
    case Unknown
}

typealias TwoFactorLoginInfo = (authCode: String, oneTimePassword: String)?

class LoginViewModel: ViewModel {
    
    let services: Services
    
    let title = MutableProperty<String?>("Login to ANZ")
    
    let username = MutableProperty<String?>(nil)
    let password = MutableProperty<String?>(nil)
    let isValid = MutableProperty<Bool>(false)
    
    var loginAction: CocoaAction?
    var loginActionBlock: Action<TwoFactorLoginInfo, AnyObject, LoginViewModelError>?
    
    required init(services: Services) {
        
        self.services = services
        
        self.loginActionBlock = Action<TwoFactorLoginInfo, AnyObject, LoginViewModelError> { input in
            
            guard let username = self.username.value else {
                print("No username")
                return SignalProducer.empty
            }
            
            guard let password = self.password.value else {
                print("No password")
                return SignalProducer.empty
            }
            
            // One time password
            
            print("has one time password? \(input)")
            
            return self.login(username, password: password, oneTimePassword: input?.oneTimePassword, authCode: input?.authCode)
            
//            // TODO: Reactify this
//            
//            let accountsViewModel = AccountsViewModel(services: self.services)
//            self.services.router.resetToRootViewModel(accountsViewModel)
//            
//            return SignalProducer.empty
        }
        
        
        self.loginActionBlock?.executing.producer.start({
            print("executing: \($0)")
        })
        
        let actionWrapper = Action<Void, Void, NoError> {
            self.loginActionBlock?.apply(nil).start { test in
                print(test)
            }
            return SignalProducer.empty
        }
        

        self.loginAction = CocoaAction(actionWrapper) { _ in print("login button tapped") }
        
        // Create a mapping to the isValid property based on the username and password
        self.isValid <~ combineLatest(self.username.producer, self.password.producer)
            .map { username, password in
                return (username?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) &&
                       (password?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0)
        }
        
    }
    
    func loginComplete(object: AnyObject) -> Void {
    
        let passcodeViewModel = PasscodeViewModel(services: self.services)
        self.services.router.pushToViewModel(passcodeViewModel)
    
    }
    
    
    func login(username: String, password: String, oneTimePassword: String?, authCode: String?) -> SignalProducer<AnyObject, LoginViewModelError> {
        
        return SignalProducer({ observer, disposable in
            
            if let oneTimePassword = oneTimePassword, authCode = authCode {
                
                self.services.api.authenticate(username, oneTimePassword: oneTimePassword, authCode: authCode, completion: { (response) -> () in
                    
                    switch (response) {
                    case .Failed(let error, let responseObject):
                        print(error)
                        print(responseObject)
                        sendError(observer, LoginViewModelError.Unknown)
                    case .Success(let responseObject):
                        print(responseObject)
                        
//                        if let sessionId = responseObject["ibSessionId"] {
//                            //                        print("FOUND sessionId \(sessionId)")
//                            //                        self.ibSessionId = sessionId as! String
//                            //                        self.api.ibSessionId = self.ibSessionId
//                        }
                        
                        sendNext(observer, responseObject)
                        sendCompleted(observer)
                        
                    }
                    
                })
                
                
            } else {
                
                self.services.api.authenticate(username, password: password, completion: { (response) -> () in
                    
                    switch (response) {
                    case .Failed(let error, _):
                        
                        switch error {
                        case .AuthCodeSent(let oneTimePassword):
                            // show alert asking for authcode
                            sendError(observer, LoginViewModelError.OneTimePasswordRequired(oneTimePassword: oneTimePassword))
                            
                            print("One Time password retrieved")
                        default:
                            
                            sendError(observer, LoginViewModelError.Unknown)
                            return;
                        }
                        
                    case .Success(let responseObject):
                        // nop? (I don't have another ANZ account to play with to get a copy of this response, so set up 2FA!) - show an alert?
                        print(responseObject)
                        sendNext(observer, "done")
                        sendCompleted(observer)
                    }
                    
                })
            }
            
            disposable.addDisposable {
                //                task.cancel()
            }
        })
        // When finished
        .observeOn(UIScheduler())
        .on(next: loginComplete)
        // Retry the api call twice before giving up.
        //.retry(2)

    }
    
    
}