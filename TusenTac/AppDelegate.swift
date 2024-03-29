//
//  AppDelegate.swift
//  TusenTac
//
//  Created by ingeborg ødegård oftedal on 18/12/15.
//  Copyright © 2015 ingeborg ødegård oftedal. All rights reserved.
//

import UIKit
import ResearchKit
import Fabric
import Crashlytics



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window?.tintColor = Color.primaryColor
        application.applicationIconBadgeNumber = 0
        
        let completedOnboarding = UserDefaults.boolForKey(UserDefaultKey.CompletedOnboarding)
        
        let onboarding = UIStoryboard(name: "onboarding", bundle: nil)
        let onboardingVC = onboarding.instantiateInitialViewController()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = main.instantiateInitialViewController()
        
        window?.rootViewController = completedOnboarding ? mainVC : onboardingVC
        
        let hasLaunchedBefore = UserDefaults.boolForKey(UserDefaultKey.hasLaunchedBefore)
        if !hasLaunchedBefore  {
            let uuid = NSUUID().UUIDString
            UserDefaults.setObject(uuid, forKey: UserDefaultKey.UUID)
            NSLog("Stored user ID \(uuid) in UserDefaults")
            
            // Set default dosages here temporarily
            UserDefaults.setObject("0", forKey: UserDefaultKey.morningDosage)
            UserDefaults.setObject("0", forKey: UserDefaultKey.nightDosage)
            UserDefaults.setObject("0", forKey: UserDefaultKey.earlierDosage)
            
            ORKPasscodeViewController.removePasscodeFromKeychain()
            NSLog("Removed passcode from Keychain")
            
            UserDefaults.setBool(true, forKey: UserDefaultKey.hasLaunchedBefore)
            NSLog("HasLaunched flag enabled in UserDefaults")
            
        }
        
        lock()
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func handleNotificationTap(userInfo: [NSObject: AnyObject]) {
        let type = userInfo[UserDefaultKey.notificationType] as! String
        NSNotificationCenter.defaultCenter().postNotificationName(type, object: nil)
    }
    
    func lock() {
        guard ORKPasscodeViewController.isPasscodeStoredInKeychain()
            && !(window?.rootViewController?.presentedViewController is ORKPasscodeViewController)
            && UserDefaults.boolForKey(UserDefaultKey.CompletedOnboarding)
            else { return }
        
        window?.makeKeyAndVisible()
        
        let passcodeVC = ORKPasscodeViewController.passcodeAuthenticationViewControllerWithText("Velkommen tilbake til TusenTac.", delegate: self) as! ORKPasscodeViewController
        window?.rootViewController?.presentViewController(passcodeVC, animated: false, completion: nil)
    }
    
    // MARK: Notification delegates
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // This method is called when the app is launched (either normally or due to a local notification’s action)
        // This method can become useful in cases you need to check the existing settings and act depending on the values that will come up. Don’t forget that users can change these settings through the Settings app, so do never be confident that the initial configuration made in code is always valid.
        
        print(notificationSettings.types.rawValue)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if (application.applicationState != UIApplicationState.Active) {
            handleNotificationTap(notification.userInfo!)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        application.applicationIconBadgeNumber = 0
        
        switch identifier {
            case "GO_ACTION"?:
                handleNotificationTap(notification.userInfo!)
            case "SNOOZE_ACTION"?:
                notification.fireDate = NSDate().dateByAddingTimeInterval(Double(60 * Notifications.snoozeDelayInMinutes))
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            default: break
        }
        
        completionHandler()
    }
    
    // MARK: Other lifecycle delegate methods

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
extension AppDelegate: ORKPasscodeDelegate {
    func passcodeViewControllerDidFinishWithSuccess(viewController: UIViewController) {
            viewController.dismissViewControllerAnimated(true, completion: nil)
            
    }
        
    func passcodeViewControllerDidFailAuthentication(viewController: UIViewController) {
            // Todo
    }
}
