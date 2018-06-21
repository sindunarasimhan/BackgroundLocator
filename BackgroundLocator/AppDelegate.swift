//
//  AppDelegate.swift
//  BackgroundLocator
//
//  Created by Y Jayaraman on 6/19/18.
//  Copyright © 2018 Y Jayaraman. All rights reserved.
//

import UIKit
import Sentry
import SwiftLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    var currentBgTaskId : UIBackgroundTaskIdentifier?
    var timer:Timer?
    var lastLocationDate : NSDate = NSDate()
    static let BACKGROUND_TIMER = 10.0 // restart location manager every 150 seconds
    static let UPDATE_SERVER_INTERVAL = 10// 1 hour - once every 1 hour send location to server
    



    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            Client.shared = try Client(dsn: "https://eab85c960f93426c967c54216ad93c8c@sentry.io/760741")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }
        
        return true
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        start()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        start()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationEnterBackground(){
        start()
    }
    
    
    func start(){
        Locator.subscribePosition(accuracy:.block, onUpdate: { (locs) -> (Void) in
            let latlongstring = String(locs.coordinate.latitude) + String(locs.coordinate.longitude)
            let lat_long_update = Event(level: .debug)
            lat_long_update.message = "Lat_Long_Update"
            lat_long_update.extra = ["lat+long+string": latlongstring]
            Client.shared?.send(event: lat_long_update) { (error) in
                // Optional callback after event has been send
            }
            
        }) { (fail, locs) -> (Void) in
        }
    }
    
    func beginNewBackgroundTask(){
        var previousTaskId = currentBgTaskId;
        currentBgTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        })
        if let taskId = previousTaskId{
            UIApplication.shared.endBackgroundTask(taskId)
            previousTaskId = UIBackgroundTaskInvalid
        }
        
        timer = Timer.scheduledTimer(timeInterval: AppDelegate.BACKGROUND_TIMER, target: self, selector: #selector(self.restart),userInfo: nil, repeats: false)
    }
    
    func isItTime(now:NSDate) -> Bool {
        let timePast = now.timeIntervalSince(lastLocationDate as Date)
        let intervalExceeded = Int(timePast) > AppDelegate.UPDATE_SERVER_INTERVAL
        return intervalExceeded;
    }
    
    @objc func restart (){
        timer?.invalidate()
        timer = nil
        start()
    }

}

