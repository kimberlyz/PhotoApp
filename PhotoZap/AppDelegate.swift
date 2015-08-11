//
//  AppDelegate.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/10/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse
import Mixpanel
import FBSDKCoreKit
import ParseUI
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mpcManager: MPCManager!
    
    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                // 1
                ErrorHandling.defaultErrorHandler(error)
            } else if let user = user {
                // if login was successful, display the TabBarController
                // 2
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                // 3
                println(self.window?.rootViewController)
                self.window?.rootViewController!.presentViewController(tabBarController, animated:true, completion:nil)
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        Mixpanel.sharedInstanceWithToken("57c3cd570c65e05727b88d2f9d8fe6da")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        
        Parse.enableLocalDatastore()
        // Set up Parse SDK
        Parse.setApplicationId("nynNgfGlqdxWbUSTVOQWpssFFHumyGd3lOKfpOgU", clientKey:
            "coum5Edl90uh0ARRSbRRiDYd5g02noZkNk5JKxLs")
        
        // Done in the background
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        /*
        let notificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge
        let settings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
        application.registerUserNotificationSettings(settings) */
        
        
        // Initialize Facebook
        // 1
        //PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // check if we have logged in user
        // 2
        let user = PFUser.currentUser()
        
        let startViewController: UIViewController;
        
        if (user != nil) {
            // 3
            // if we have a user, set the TabBarController to be the initial View Controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            
            mpcManager = MPCManager()

        } else {
            // 4
            // Otherwise set the LoginViewController to be the first
            let loginViewController = PFLogInViewController()
            loginViewController.fields = .UsernameAndPassword | .LogInButton | .SignUpButton | .PasswordForgotten //| .Facebook
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController?.delegate = parseLoginHelper
            
            startViewController = loginViewController
        }
        
        // 5
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController;
        self.window?.makeKeyAndVisible()
        
        
        
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        
        
       // application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
    
        // Override point for customization after application launch.
        //return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        return false
    }
    
    //MARK: Facebook Integration
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //FBSDKAppEvents.activateApp()
    }
    
    /*
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    } */
    

    /*
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
       // application.applicationIconBadgeNumber = 0 
        /*
        - (void)showAlarm:(NSString *)text {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alarm"
            message:text delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
            [alertView show];
        } */
        println("WHattt?")

        let alertView = UIAlertView(title:"", message: "Photo Successfully Sent :D", delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
        
        /*
        if (alertView) {
            alertView.release()
        } */
        
        /*
        initWithTitle:@"MyAlertView"
        message:notification.alertBody
        delegate:self cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
        [alertView show];
        if (alertView) {
            [alertView release];
        } */
       
    } */

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
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

