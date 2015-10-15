//
//  AppDelegate.swift
//  ANZGoMoney
//
//  Created by William Townsend on 24/08/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var router: Router?
    var viewModelServices: ViewModelServices?
    let api = ANZGoMoneyAPI()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

//        DeviceManager.sharedInstance.removeDeviceToken()
        
        self.router = Router()
        
        let services = Services(router: self.router!, api: self.api)
        let viewModel = self.rootViewModel(services)
        self.router?.resetToRootViewModel(viewModel)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = self.router?.rootViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func rootViewModel(services: Services) -> ViewModel {
        if let deviceToken = DeviceManager.sharedInstance.retrieveDeviceToken() {
            print("Signed in, well, have a token")
            
//            api.authenticate(deviceToken.deviceToken, pin: deviceToken.passcode, completion: { (response) -> () in
//                print(response)
//            })
//            
            let viewModel = AccountsViewModel(services: services)
            return viewModel
            
        } else {
        
            let viewModel = LoginViewModel(services: services)
            viewModel.username.value = Private.username
            viewModel.password.value = Private.password
            return viewModel
            
        }
    }
}
