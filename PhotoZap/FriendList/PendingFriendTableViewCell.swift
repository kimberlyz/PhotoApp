//
//  PendingFriendTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/28/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class PendingFriendTableViewCell: UITableViewCell {


    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pendingImageView: UIImageView!
    
    var user: PFUser? {
        didSet {
            if let user = user {
                user.fetchIfNeeded()
                usernameLabel.text = user["username"] as? String
            }
        }
    }

}
