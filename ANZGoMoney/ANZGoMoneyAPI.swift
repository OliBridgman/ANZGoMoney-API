//
//  ANZGoMoneyAPI.swift
//  ANZGoMoney
//
//  Created by William Townsend on 26/08/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class ANZGoMoneyAPI: NSObject, NSURLSessionDelegate {
    
    // MARK: - Types
    
    typealias JSONDictionary = [String: AnyObject]
    
    public enum APIError: ErrorType {
        case Unknown
        case HTTPError(code: Int)                       // Unknown http error
        case InvalidResponse
        case LoginDenied                                // "loginDenied"
        case AuthCodeSent(oneTimePassword: String)      // "authCodeSent"
        case InvalidAuthCode                            // "invalidAuthCode"
        
    }
    
    public enum APIResponse {
        case Failed(APIError, AnyObject?)
        case Success(response: AnyObject)
    }
    
    public typealias Completion = (success: Bool) -> ()
    
    // MARK: - Properties
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
            let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,credential);
        }
        
    }
    
    private let APIKey: String
    
    public var ibSessionId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("sessionId") as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "sessionId")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private lazy var urlSession: NSURLSession = {
        let urlSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlSessionConfiguration.HTTPAdditionalHeaders = ["Accept": "application/json"]
        
//        let cs = NSHTTPCookieStorage()
//        cs.cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
//        cs.cookies
//        urlSessionConfiguration.HTTPCookieSt
        let urlSession = NSURLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
        
        return urlSession
    }()
    
    private let endpoint = "https://secure.anz.co.nz/api/v5/"
    
    // MARK: - Initializers
    
    public init(APIKey: String = "19a20168-a831-4bae-bde3-7c5955ce816c") {
        self.APIKey = APIKey
        super.init()
    }
    
    // MARK: - Functions
    
    private func parseAPIErrorFromResponse(response: NSHTTPURLResponse, jsonDictionary: JSONDictionary) -> APIError? {
        
        if case (200...299) = response.statusCode {
            return nil
        }
        
        guard let code = jsonDictionary["code"] as? String else {
            return .HTTPError(code: response.statusCode)
        }
        
        switch code {
        case "loginDenied":
            return .LoginDenied
        case "authCodeSent":
            if let errorParameters = jsonDictionary["errorParameters"] as? [String: AnyObject],
                let oneTimePassword = errorParameters["oneTimePassword"] as? String {
                    return .AuthCodeSent(oneTimePassword: oneTimePassword)
            }
        case "invalidAuthCode":
            return .InvalidAuthCode
        default:
            return .Unknown
        }
        
        return .Unknown
        
    }
    
//    func request(path: String, method: String = "POST", payload: JSONDictionary? = nil) -> SignalProducer<(NSData, NSURLResponse), NSError> {
//        
//        var jsonData: NSData? = nil
//        
//        if let payload = payload {
//            do {
//                jsonData = try NSJSONSerialization.dataWithJSONObject(payload, options: [])
//            } catch {
//                return SignalProducer.empty
//            }
//        }
//        
//        guard let url = NSURL(string: "\(endpoint)\(path)") else {
//            return SignalProducer.empty
//        }
//        
//        
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPBody = jsonData;
//        request.HTTPMethod = method
//        
//        var httpHeaders = [
//            "Api-Key": APIKey,
//            "Content-Type": "application/json",
//            "User-Agent": "goMoney NZ/4.6.0/Wifi/iPhone7,2/9.0/",
//            "Api-Request-Id": NSUUID().UUIDString
//        ]
//        
//        if let ibSessionId = self.ibSessionId {
//            print("SessionID: \(self.ibSessionId)")
//            httpHeaders.updateValue(ibSessionId, forKey: "IB-Session-ID")
//            print("New Headers: \(httpHeaders)")
//        } else {
//            print("NO SESSION ID SET")
//        }
//        
//        request.allHTTPHeaderFields = httpHeaders
//        
//        return self.urlSession.rac_dataWithRequest(request)
//    }
    
    
    private func sendRequest(path: String, method: String = "POST", payload: JSONDictionary? = nil, completion: ((response: APIResponse) -> ())? = nil) {
        
        do {
            
            var json: NSData? = nil
            
            if let payload = payload {
                json = try NSJSONSerialization.dataWithJSONObject(payload, options: [])
            }
        
            if let url = NSURL(string: "\(endpoint)\(path)") {
                
                let request = NSMutableURLRequest(URL: url)
                
                if json != nil {
                    request.HTTPBody = json;
                }
                
                request.HTTPMethod = method
                
                var httpHeaders = [
                    "Api-Key": APIKey,
                    "Content-Type": "application/json",
                    "User-Agent": "goMoney NZ/4.6.0/Wifi/iPhone7,2/9.0/",
                    "Api-Request-Id": NSUUID().UUIDString
                ]
                
                if let ibSessionId = self.ibSessionId {
                    print("SessionID: \(self.ibSessionId)")
                    httpHeaders.updateValue(ibSessionId, forKey: "IB-Session-ID")
                    print("New Headers: \(httpHeaders)")
                } else {
                    print("NO SESSION ID SET")
                }
                
                request.allHTTPHeaderFields = httpHeaders
                
                let task = urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    
                    if let error = error {
                        NSLog("%@", error)
                    }
                    
                    print(error)
                    
                    do {
                        if error != nil {
                            completion?(response: .Failed(.Unknown, nil))
                            return
                        }
                        
                        guard let response = response as? NSHTTPURLResponse, let data = data else {
                            completion?(response: .Failed(.InvalidResponse, nil))
                            return
                        }
                        
                        guard let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? Dictionary<String, AnyObject> else {
                            completion?(response: .Failed(.InvalidResponse, nil))
                            return;
                        }
                        
                        if let error = self.parseAPIErrorFromResponse(response, jsonDictionary: jsonDictionary) {
                            completion?(response: .Failed(error, nil))
                        }
                        
                        // Hijack session id if possible
                        
                        if let ibSessionId = jsonDictionary["ibSessionId"] as? String {
                            self.ibSessionId = ibSessionId
                            print("Setting Sessions id: \(ibSessionId)")
                        }
                        
                        completion?(response: .Success(response: jsonDictionary))
                        return
                    }
                    catch {
                        completion?(response: .Failed(.Unknown, nil))
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
    
    public func authenticate(user: String, password: String, completion: ((response: APIResponse) -> ())? = nil) {
        
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
            
            completion?(response: response)
        }
    }
    
    public func authenticate(user: String, oneTimePassword: String, authCode: String, completion: ((response: APIResponse) -> ())? = nil) {
        
        let payload: JSONDictionary = [
            "userId": user,
            "oneTimePassword": oneTimePassword,
            "authCode": authCode
        ]
        
        self.sendRequest("u/sessions", payload: payload) { (response) -> () in
            
            switch response {
            case .Failed(let reason):
                print("Request Failed. Reason: \(reason)")
            case .Success(let response):
                print(response)
            }
            
            completion?(response: response)
            
        }
    }
    
    public func authenticate(deviceToken: String, pin: String, completion: ((response: APIResponse) -> ())? = nil) {
        
        let payload: JSONDictionary = [
            "deviceToken": deviceToken,
            "pin": pin
        ]
        
        self.sendRequest("u/sessions", payload: payload) { (response) -> () in
            
            switch response {
            case .Failed(let reason):
                print("Request Failed. Reason: \(reason)")
            case .Success(let response):
                print(response)
            }
            
            completion?(response: response)
            
        }
    }
    
    public func verifyPin(pin: String, deviceDescription: String, completion: ((response: APIResponse) -> ())? = nil) {
        
        let payload: JSONDictionary = [
            "pin": pin,
            "newDevice": [
                "description": deviceDescription
            ]
        ]
        
        self.sendRequest("s/pins/verify", payload: payload) { (response) -> () in
            
            switch response {
            case .Failed(let reason):
                print("Request Failed. Reason: \(reason)")
            case .Success(let response):
                print(response)
            }
            
            completion?(response: response)
            
        }
    }
    
    public func createPin(pin: String, deviceToken: String, completion: ((response: APIResponse) -> ())? = nil) {
        
        let payload: JSONDictionary = [
            "pin": pin,
            "deviceToken": deviceToken
        ]
        
        self.sendRequest("s/pins/reset", payload: payload) { (response) -> () in
            
            switch response {
            case .Failed(let reason):
                print("Request Failed. Reason: \(reason)")
            case .Success(let response):
                print(response)
            }
            
            completion?(response: response)
            
        }
    }
    
    public func fetchAccounts(completion: ((response: APIResponse) -> ())? = nil) {
        
        self.sendRequest("s/accounts", method: "GET") { (response) -> () in
            
            switch response {
            case .Failed(let reason):
                print("Request Failed. Reason: \(reason)")
            case .Success(let response):
                print(response)
            }
            
            completion?(response: response)
            
        }
    }
}


/*

code = userAlreadyHasASession;
devDescription = "User is attempting to login with an currently open Session";
httpStatus = 400;
serverDateTime = "2015-10-17T00:42:11.193+1300";
sinceVersion = 5;

*/