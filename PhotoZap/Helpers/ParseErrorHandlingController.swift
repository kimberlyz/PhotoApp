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
    //static var loginViewController = PFLogInViewController()
    
    //static var presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
    
    //static var parseLoginHelper: ParseLoginHelper
    
    class func handleParseError(error: NSError) {
        if error.domain != PFParseErrorDomain {
            return
        }
        
        func handleInvalidSessionTokenError() {
            
            let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
            let loginViewController = PFLogInViewController()
            
            let alertController = UIAlertController(title: "Logged out.", message: "Please log back in to continue using PhotoZap.", preferredStyle: .Alert)
            let loginAction = UIAlertAction(title: "Login", style: .Default) { (action) in
                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                presentingViewController?.presentViewController(loginViewController, animated: true, completion: nil)
            }
            alertController.addAction(loginAction)
            
            presentingViewController?.presentViewController(alertController, animated: true, completion: nil)
            

            /*
            if presentingViewController is UITabBarController {
                println("Whatttt")
            } else {
                presentingViewController?.presentViewController(loginViewController, animated: true, completion: nil)
            } */


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