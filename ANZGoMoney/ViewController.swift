//
//  ViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 24/08/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Actions
    
    @IBAction func touchedButton(sender: AnyObject) {
        
        let api = ANZGoMoneyAPI()
        
        api.authenticate("12345678", password: "testtest") { (success) -> () in
            
        }
        
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
