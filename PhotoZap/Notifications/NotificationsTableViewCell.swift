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
    
    //var fromUser : PFUser?
    
    var fromUser: PFUser? {
        didSet {
            if let fromUser = fromUser {
                fromUser.fetchIfNeeded()
                usernameLabel.text = fromUser["username"] as? String
            }
        }
    }

}
