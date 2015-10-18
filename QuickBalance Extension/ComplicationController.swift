//
//  ComplicationController.swift
//  QuickBalance Extension
//
//  Created by Will Townsend on 15/10/15.
//  Copyright © 2015 William Townsend. All rights reserved.
//

import ClockKit
import ReactiveCocoa

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let api = ANZGoMoneyAPI()
    var text = "Loading..."
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.HideOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        let template = defaultTemplate()
        let date = NSDate()
        
        guard let _ = DeviceManager.sharedInstance.retrieveDeviceToken() else {
            
            template.textProvider = CLKSimpleTextProvider(text: "FAILED")
            
            handler(CLKComplicationTimelineEntry(date: date, complicationTemplate: template))
            
            return
        }
        
        template.textProvider = CLKSimpleTextProvider(text: self.text)
        handler(CLKComplicationTimelineEntry(date: date, complicationTemplate: template))
        
    }
        
    func defaultTemplate() -> CLKComplicationTemplateUtilitarianLargeFlat {
        let placeholder = CLKComplicationTemplateUtilitarianLargeFlat()
        placeholder.textProvider = CLKSimpleTextProvider(text: "Loading...t")
        return placeholder
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        
        let date = NSDate().dateByAddingTimeInterval(60*5)
        handler(date);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        if complication.family == CLKComplicationFamily.UtilitarianLarge {
            handler(defaultTemplate())
            return
        }
        
        handler(nil)
    }
    
    
    func requestedUpdateDidBegin() {
        
        guard let deviceToken = DeviceManager.sharedInstance.retrieveDeviceToken() else {
            return
        }
        
        self.api.authenticatedFetchAccountsSignal(deviceToken.deviceToken, pin2: deviceToken.passcode).observeOn(UIScheduler()).startWithNext { accounts in
            
            let account = accounts.filter { $0.nickname == "MAIN" }
            
            if let account = account.first {
                
                DeviceManager.sharedInstance.keychain[""] = "MAIN: $\(account.balance)"
                
                self.text = "MAIN: $\(account.balance)"
            } else {
                self.text = "FAILED"
            }

            let server = CLKComplicationServer.sharedInstance()
            
            for comp in (server.activeComplications) {
                server.reloadTimelineForComplication(comp)
            }
            
        }
        
    }
    
}
