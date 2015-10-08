//
//  RouterViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 8/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import UIKit

class RouterViewController: UIViewController {
    
    // MARK: Variables
    
    var viewController: UIViewController? = nil
    
    // MARK: Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Functions
    
    func showViewController(viewController: UIViewController, animated: Bool = false) {
        
        let previousViewController = self.viewController
        
        self.viewController = viewController
        
        viewController.view.frame = self.view.frame
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        
        // Remove old view controller
        previousViewController?.willMoveToParentViewController(nil)
        
        let completion = { () -> Void in
            viewController.didMoveToParentViewController(self)
            previousViewController?.view.removeFromSuperview()
            previousViewController?.removeFromParentViewController()
        }
        
        if animated {
            
            viewController.view.alpha = 0.0
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                viewController.view.alpha = 1.0
                //                previousViewController?.view.layer.opacity = 0.0;
                
                }, completion: { (let completed) -> Void in
                    completion()
            })
            
        } else {
            completion()
        }
    }
    
}