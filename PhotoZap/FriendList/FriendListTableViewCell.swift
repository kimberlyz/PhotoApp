//
//  FriendListTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/14/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class FriendListTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: PFUser? {
        didSet {
            /*
            if let user = user {
                user.fetchIfNeededInBackground()
                usernameLabel.text = user["username"] as? String
            } */
            if let user = user {
                user.fetchIfNeededInBackgroundWithBlock({ (userObject: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        ParseErrorHandlingController.handleParseError(error!)
                    } else {
                        let userPFObject = userObject as! PFUser
                        self.usernameLabel.text = userPFObject["username"] as? String
                    }
                })
                //usernameLabel.text = user["username"] as? String
            }
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
