//
//  LoginViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 1/14/16.
//  Copyright (c) 2016 Kimberly Zai. All rights reserved.
//

import Foundation
import UIKit
import Parse

class LoginViewController : UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var emailField: UITextField!

    override func viewWillAppear(animated: Bool) {
        confirmPasswordField.hidden = true
        emailField.hidden = true
    }
    override func viewDidLoad() {
        
    }
    
    // UHH
    override func viewDidAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainScreen = storyBoard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(mainScreen, animated: true, completion: nil)
            
        } else {
            // show the signup or login screen (do nothing)
        }
    }
    func makeNewAccount() {
        let user = PFUser()
        user.username = usernameField.text!
        user.password = confirmPasswordField.text!
        user.email = emailField.text!
        // other fields can be set just like with PFObject
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? NSString
                // Show the errorString somewhere and let the user try again
                print("Error: \(errorString)")
                // display an error that the user couldn't make an account
                let parseErrorAlert = UIAlertController(title: "Uh Oh!", message: "You couldn't make an account due to \(errorString!)", preferredStyle: UIAlertControllerStyle.Alert)
                parseErrorAlert.addAction(UIAlertAction(title: "Try again!", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(parseErrorAlert, animated: true, completion: nil)
            } else {
                // Hooray! Let them use the app now.
                self.loginButtonTapped(self)
            }
        }
    }
    
    @IBAction func createAccountButtonTapped(sender: AnyObject) {
        
        if confirmPasswordField.hidden == true || emailField.hidden == true {
            // tell our user there's just a few more things to do
            let moreStepsAlert = UIAlertController(title: "Hey!", message: "You're almost done setting up your account. Just need you to confirm some things!", preferredStyle: UIAlertControllerStyle.Alert)
            
            moreStepsAlert.addAction(UIAlertAction(title: "Sure no problem!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(moreStepsAlert, animated: true, completion: {
                // then display the extra fields they need to fill out
                self.confirmPasswordField.hidden = false
                self.emailField.hidden = false
            })
            
            // then display the extra fields they need to fill it out
        } else {
            // make an account
            
            // make sure fields aren't blank
            if emailField.text != "" && passwordField.text != "" && usernameField.text != "" && confirmPasswordField.text != "" {
                
                // make sure password is at least 6 characters long
                if count(passwordField.text!) >= 6 || count(confirmPasswordField.text!) >= 6 {
                    
                    // make sure passwordfield matches confirmation field
                    if passwordField.text! == confirmPasswordField.text! {
                        // make new account
                        makeNewAccount()
                    } else {
                        // display error that passwords do not match
                        let passMatchAlert = UIAlertController(title: "Uh Oh!", message: "Your password doesn't match the password you typed into the confirmation field!", preferredStyle: UIAlertControllerStyle.Alert)
                        passMatchAlert.addAction(UIAlertAction(title: "Try again!", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(passMatchAlert, animated: true, completion: nil)
                    }
                    
                } else {
                    // display error that passwords do not match
                    let passLengthAlert = UIAlertController(title: "Uh Oh!", message: "Your password isn't long enough! Your password must be 6 characters long.", preferredStyle: UIAlertControllerStyle.Alert)
                    passLengthAlert.addAction(UIAlertAction(title: "Try again!", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(passLengthAlert, animated: true, completion: nil)
                }
                
            } else {
                // display error that user is missing a field
                let missingFieldAlert = UIAlertController(title: "Uh Oh!", message: "You must have skipped over one of the required fields.", preferredStyle: UIAlertControllerStyle.Alert)
                missingFieldAlert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(missingFieldAlert, animated: true, completion: nil)
            }

        }
        
    }
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        if usernameField.text != "" || passwordField.text != "" {
            PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    // Do stuff after successful login
                    self.performSegueWithIdentifier("showMainScreen", sender: self)
                } else {
                    // Login failed. Check to see why
                    let theError: AnyObject? = error!.userInfo?["error"]
                    
                    let wrongLoginAlert = UIAlertController(title: "Hey!", message: "Failed to login due to: \(theError!)", preferredStyle: UIAlertControllerStyle.Alert)
                    wrongLoginAlert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(wrongLoginAlert, animated: true, completion: nil)
                }
            }
        } else {
            let noTextAlert = UIAlertController(title: "Excuse me!", message: "You must type in a username and password!", preferredStyle: UIAlertControllerStyle.Alert)
            noTextAlert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(noTextAlert, animated: true, completion: nil)
        }

    }
}