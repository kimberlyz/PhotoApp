//
//  FriendRequestTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/27/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//


import UIKit
import Parse

protocol FriendRequestTableViewCellDelegate: class {
    func cell(cell: FriendRequestTableViewCell, didSelectConfirmRequest user: PFUser)
}

class FriendRequestTableViewCell: UITableViewCell {
    

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    
    weak var delegate: FriendRequestTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            if let user = user {
                user.fetchIfNeededInBackgroundWithBlock({ (userObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        ParseErrorHandlingController.handleParseError(error!)
                    } else {
                        let userPFObject = userObject as! PFUser
                        self.usernameLabel.text = userPFObject["username"] as? String
                        self.friendButton.selected = false
                        self.friendButton.enabled = true
                    }
                })
            }
        }
    }
    
    @IBAction func friendButtonTapped(sender: AnyObject) {
        friendButton.enabled = false
        delegate?.cell(self, didSelectConfirmRequest: user!)
    }    
}
