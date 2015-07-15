//
//  AddFriendTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/14/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

protocol AddFriendTableViewCellDelegate: class {
    func cell(cell: AddFriendTableViewCell, didSelectFriendUser user: PFUser)
    func cell(cell: AddFriendTableViewCell, didSelectUnfriendUser user: PFUser)
}

class AddFriendTableViewCell: UITableViewCell {
    
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
            Change the state of the friend button based on whether or not
            it is possible to friend a user.
            */
            
            if let canFriend = canFriend {
                friendButton.selected = !canFriend
            }
        }
    }
    

    @IBAction func friendButtonTapped(sender: AnyObject) {
        
        if let canFriend = canFriend where canFriend == true {
            delegate?.cell(self,didSelectFriendUser: user!)
            self.canFriend = false
        } else {
            delegate?.cell(self, didSelectUnfriendUser: user!)
            self.canFriend = true
        }
    }
    
    /*
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
*/

}
