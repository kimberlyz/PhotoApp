
//  ReceiveZapTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit

class ReceiveZapTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
//    var connection : Connection {
//    didSet {
    //        cell.usernameLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
    //        cell.connectionStatusLabel.text = self.connectionState
//    }
//}
    
    func displayStatus() {
        // is my peer a member of appDelegate.mpcManager.connectedPeers
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
