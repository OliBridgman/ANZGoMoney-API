//
//  Router.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import UIKit

/// Provides the navigation methods to navigate between ViewModels
class Router {
    
    /// The RouterViewController that has the methods to transition between ViewControllers with view controller containment.
    let rootViewController: RouterViewController = RouterViewController()
    
    var navigationControllers = [UINavigationController]()
    
    /// Instantiates the Router with the rootViewModel
    init(rootViewModel: ViewModel? = nil) {
        
        if let rootViewModel = rootViewModel, let viewController = self.viewControllerForViewModel(rootViewModel) {
            
            var viewController = viewController
            
            if let navigationController = viewController as? UINavigationController {
                self.navigationControllers.append(navigationController)
            } else {
                let navigationController = UINavigationController(rootViewController: viewController)
                self.navigationControllers.append(navigationController)
                viewController = navigationController
            }
            self.rootViewController.showViewController(viewController)
        }
    }
    
    func resetToRootViewModel(viewModel: ViewModel) {
        
        guard let viewController = self.viewControllerForViewModel(viewModel) else {
            print("Unable to find viewController")
            return
        }
        
        if let navigationController = viewController as? UINavigationController {
            self.navigationControllers.append(navigationController)
            self.rootViewController.showViewController(navigationController)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            self.navigationControllers.append(navigationController)
            self.rootViewController.showViewController(navigationController, animated: true)
        }
    }
    
    func pushToViewModel(viewModel: ViewModel, animated: Bool = true) {
        
        guard let viewController = self.viewControllerForViewModel(viewModel) else {
            print("Unable to find viewController")
            return
        }
        
        if let navigationController = self.navigationControllers.last {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    func presentToViewModel(viewModel: ViewModel, animated: Bool = true) {
        
        guard let viewController = self.viewControllerForViewModel(viewModel) else {
            print("Unable to find viewController")
            return
        }
        
        if let navigationController = viewController as? UINavigationController {
            self.navigationControllers.last?.presentViewController(navigationController, animated: animated, completion: nil)
            self.navigationControllers.append(navigationController)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            self.navigationControllers.last?.presentViewController(navigationController, animated: animated, completion: nil)
            self.navigationControllers.append(navigationController)
        }
    }
    
    func dismissViewModel(animated: Bool = true) {
        self.navigationControllers.popLast()
        self.navigationControllers.last?.dismissViewControllerAnimated(animated, completion: nil)
    }
    
    private func viewControllerForViewModel(viewModel: ViewModel) -> UIViewController? {
        
        if let viewModel = viewModel as? LoginViewModel {
            return LoginViewController(viewModel: viewModel)
        } else if let viewModel = viewModel as? AccountsViewModel {
            return AccountsViewController(viewModel: viewModel)
        }
        
        print("ERROR: Unable to find viewController\n\nNo View controller found for the viewModel \(viewModel)\n\n Did you forget to add it to the Router.viewControllerForViewModel() method?\n\n")
        
        
        return nil
    }
}