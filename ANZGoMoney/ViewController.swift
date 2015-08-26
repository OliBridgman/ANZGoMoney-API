//
//  ViewController.swift
//  ANZGoMoney
//
//  Created by William Townsend on 24/08/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import UIKit

public struct ANZGoMoneyAPI {
    
    // MARK: - Types
    typealias JSONDictionary = [String: AnyObject]
    
    public enum APIError: ErrorType {
        case Unknown
        case InvalidResponse
        case LoginDenied
    }
    
    public enum RequestResponse {
        case Failed(APIError, AnyObject?)
        case Success(response: AnyObject)
    }
    
    public typealias Completion = (success: Bool) -> ()
    
    private let APIKey = "9b415be2-1a04-493c-b0e7-7895c6242698"
    private var token: String
    private var URLSession: NSURLSession
    private let endpoint = "https://secure.anz.co.nz/api/v5/"
    
    // MARK: - Initializers
    
    public init(token: String = "", identifier: String? = nil, URLSession: NSURLSession = NSURLSession.sharedSession()) {
        self.token = token
        self.URLSession = URLSession
    }
    
//    private var defaultProperties: [String: AnyObject] {
//        let properties: [String: AnyObject] = [
//            "$manufacturer": "Apple"
//        ]
//        
//        return properties
//    }
    
    private func sendRequest(path: String, method: String = "POST", payload: JSONDictionary, completion: ((response: RequestResponse) -> ())? = nil) {
        
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(payload, options: [])
            
            if let url = NSURL(string: "\(endpoint)\(path)") {
                
                let request = NSMutableURLRequest(URL: url)
                
                request.HTTPBody = json;
                request.HTTPMethod = method
                request.allHTTPHeaderFields = [
                    "Api-Key": APIKey,
                    "Content-Type": "application/json",
                    "User-Agent": "goMoney NZ/4.6.0/Wifi/iPhone8,2/9.15/",
                    "Api-Request-Id": NSUUID().UUIDString
                ]
                
                let task = URLSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil {
                        completion?(response: .Failed(.Unknown, nil))
                        return
                    }
                    
                    guard let response = response as? NSHTTPURLResponse, let data = data else {
                        completion?(response: .Failed(.InvalidResponse, nil))
                        return
                    }
                        
                    do {
                        
                        guard let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? Dictionary<String, AnyObject> else {
                            completion?(response: .Failed(.InvalidResponse, nil))
                            return;
                        }
                        
                        print(jsonDictionary)
                        
                        if response.statusCode != 200 {
                            
                            // There is an error of some sort
                            // The API is nice enough to have a dev description and a "code" which
                            // appears to tell clients what action to take.
                            
                            guard let code = jsonDictionary["code"] as? String, let devDescription = jsonDictionary["devDescription"] as? String else {
                                completion?(response: .Failed(.Unknown, nil))
                                return
                            }
                            
                            print("Code: \(code) & dev: \(devDescription)")
                            completion?(response: .Failed(.LoginDenied, jsonDictionary))
                            return
                            
                        }
                        
                        // Completion Handler
                        
                        completion?(response: .Success(response: jsonDictionary))
                        return
                        
                    } catch {
                        completion?(response: .Failed(.InvalidResponse, nil))
                        return
                    }
                    
                    
                })
                
                print(request)
                task.resume()
                
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            completion?(response: .Failed(.InvalidResponse, nil))
            return
        } catch {
            print("Error")
            completion?(response: .Failed(.InvalidResponse, nil))
            return
        }
        
    }
    
    public func authenticate(user: String, password: String, completion: Completion? = nil) {

        let payload: JSONDictionary = [
            "userId": user,
            "password": password
        ]
        
        self.sendRequest("u/sessions", payload: payload) { (response) -> () in
            
            switch response {
            case .Failed(let reason):
                print("Request Failed. Reason: \(reason)")
            case .Success(let response):
                print(response)
            }
            
        }
        
        
    }
    
}

class ViewController: UIViewController {
    
    
    
    @IBAction func touchedButton(sender: AnyObject) {
        
        let api = ANZGoMoneyAPI()
        
        api.authenticate("12345678", password: "testtest") { (success) -> () in
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
