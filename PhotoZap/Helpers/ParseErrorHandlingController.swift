//
//  ParseErrorHandlingController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/12/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import Parse
import ParseUI

class ParseErrorHandlingController {
    static var loginViewController = PFLogInViewController()
    
    //static var presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
    
    static var parseLoginHelper: ParseLoginHelper = ParseLoginHelper { user, signUpController, error in
    // Initialize the ParseLoginHelper with a callback
        if let error = error {
            // 1
            ErrorHandling.defaultErrorHandler(error)
        } else if let user = user {
            // if login was successful, display the TabBarController
            // 2
            PFUser.enableRevocableSessionInBackground()
    
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
    
            if signUpController == nil {

                loginViewController.presentViewController(tabBarController, animated:true, completion:nil)
            } else {
                signUpController!.presentViewController(tabBarController, animated: true, completion: nil)
            }
    
        }
    }

    
    class func handleParseError(error: NSError) {
        if error.domain != PFParseErrorDomain {
            return
        }
        
        func handleInvalidSessionTokenError() {
            
            let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController

            loginViewController.fields = .UsernameAndPassword | .LogInButton | .SignUpButton | .PasswordForgotten //| .Facebook
            loginViewController.delegate = parseLoginHelper
            loginViewController.signUpController?.delegate = parseLoginHelper
            
            presentingViewController?.presentViewController(loginViewController, animated: true, completion: nil)
        }
        
        switch (error.code) {
        case PFErrorCode.ErrorInvalidSessionToken.rawValue:
            handleInvalidSessionTokenError()
        default:
            ErrorHandling.defaultErrorHandler(error)

        }

    }
    
    /*
    // In all API requests, call the global error handler, e.g.
    let query = PFQuery(className: "Object")
    query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
    if error == nil {
    // Query Succeeded - continue your app logic here.
    } else {
    // Query Failed - handle an error.
    ParseErrorHandlingController.handleParseError(error)
    } */
}