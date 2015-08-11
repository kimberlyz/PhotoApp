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
    func cell(cell: FriendRequestTableViewCell, didSelectRejectRequest user: PFUser)
}

class FriendRequestTableViewCell: UITableViewCell {
    

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    weak var delegate: FriendRequestTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            if let user = user {
                user.fetchIfNeeded()
                usernameLabel.text = user["username"] as? String
            }
        }
    }
    
    @IBAction func friendButtonTapped(sender: AnyObject) {
        
        friendButton.selected = true
        delegate?.cell(self, didSelectConfirmRequest: user!)
    }
    
    @IBAction func rejectButton(sender: AnyObject) {
        delegate?.cell(self, didSelectRejectRequest: user!)
    }
    
    
}
