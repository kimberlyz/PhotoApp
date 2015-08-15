//
//  NotificationsTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/4/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var notificationsImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //var fromUser : PFUser?
    
    var fromUser: PFUser? {
        didSet {
//            if let fromUser = fromUser {
//                fromUser.fetchIfNeeded()
//                usernameLabel.text = fromUser["username"] as? String
//            }
            if let fromUser = fromUser {
                fromUser.fetchIfNeededInBackgroundWithBlock({ (userObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        ParseErrorHandlingController.handleParseError(error!)
                    } else {
                        let userPFObject = userObject as! PFUser
                        self.usernameLabel.text = userPFObject["username"] as? String
                    }
                })
            }
        }
    }
    
    var toUser: PFUser? {
        didSet {
            if let toUser = toUser {
                toUser.fetchIfNeededInBackgroundWithBlock({ (userObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        ParseErrorHandlingController.handleParseError(error!)
                    } else {
                        let userPFObject = userObject as! PFUser
                        self.usernameLabel.text = userPFObject["username"] as? String
                    }
                })
            }
            
//            if let toUser = toUser {
//                toUser.fetchIfNeeded()
//                usernameLabel.text = toUser["username"] as? String
//            }
        }
    }

}
