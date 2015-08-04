//
//  ChooseFriendsTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class ChooseFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var selectedFriendButton: UIButton!
    
    
    var user: PFUser? {
        didSet {
            if let user = user {
                user.fetchIfNeeded()
                usernameLabel.text = user["username"] as? String
            }
        }
    }
    
    var canSelect: Bool? = true {
        didSet {
            /*
            Change the state of the friend button based on whether or not
            it is possible to friend request a user.
            */
            if let canSelect = canSelect {
                println(canSelect)
                selectedFriendButton.selected = !canSelect
            }
        }
    }

    
}
