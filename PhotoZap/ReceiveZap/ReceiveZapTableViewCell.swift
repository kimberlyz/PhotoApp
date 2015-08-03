
//  ReceiveZapTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ReceiveZapTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var peer : MCPeerID?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // this view can be in two different states
    enum State {
        case NotConnected
        case Connecting
        case Connected
    }
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .NotConnected {
        didSet {
            switch (state) {
            case .NotConnected:
                connectionStatusLabel.text = "Not Connected"
                activityIndicatorView.stopAnimating()
                
            case .Connecting:
                connectionStatusLabel.text = ""
                activityIndicatorView.startAnimating()
                
            case .Connected:
                connectionStatusLabel.text = "Connected"
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    
//    var connection : Connection {
//    didSet {
    //        cell.usernameLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
    //        cell.connectionStatusLabel.text = self.connectionState
//    }
//}
    
    func displayStatus() {
        usernameLabel.text = peer?.displayName
        
        state = .NotConnected
        
        for connectedPeer in appDelegate.mpcManager.connectedPeers {
            if peer == connectedPeer {
                state = .Connected
            }
        }
        
        
        // is my peer a member of appDelegate.mpcManager.connectedPeers
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
