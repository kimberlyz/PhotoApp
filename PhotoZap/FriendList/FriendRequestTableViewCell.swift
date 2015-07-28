//
//  FriendRequestTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/27/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

/*
import UIKit
import Parse

protocol FriendRequestTableViewCellDelegate: class {
    func cell(cell: AddFriendTableViewCell, didSelectFriendUser user: PFUser)
    func cell(cell: AddFriendTableViewCell, didSelectUnfriendUser user: PFUser)
}

class FriendRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    weak var delegate: AddFriendTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
        }
    }
    
    var canFriend: Bool? = true {
        didSet {
            /*
            Change the state of the follow button based on whether or not
            it is possible to follow a user.
            */
            if let canFriend = canFriend {
                friendButton.selected = !canFriend
            }
        }
    }
    
    
    @IBAction func friendButtonTapped(sender: AnyObject) {
        
        if let canFriend = canFriend where canFriend == true {
            delegate?.cell(self, didSelectFriendUser: user!)
            self.canFriend = false
        } else {
            delegate?.cell(self, didSelectUnfriendUser: user!)
            self.canFriend = true
        }
    } 
    
}
*/