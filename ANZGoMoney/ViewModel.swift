//
//  ViewModel.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ANZGoMoneyAPI

/// All ViewModels should implement this protocol. Provides common accessors for the views.
protocol ViewModel {
    
    /// Required initialiser with the services to be used.
    init(services: Services)
    
    /// The Services that the viewModel will use
    var services: Services { get }
    
    /// Title of the view
    var title: MutableProperty<String?> { get }
}

/// Defines a protocol for all the view controllers to follow
protocol ViewModelViewController {
    
    typealias T: ViewModel
    
    var viewModel: T { get }
    
    init(viewModel: T)
    
}

/// Provides access to Services that the views can use.
protocol ViewModelServices {
    /// The View Router to use
    var router: Router { get }
    var api: ANZGoMoneyAPI { get }
}

struct Services: ViewModelServices {
    
    let router: Router
    let api: ANZGoMoneyAPI
    
    init(router: Router, api: ANZGoMoneyAPI) {
        self.router = router
        self.api = api
    }
}
