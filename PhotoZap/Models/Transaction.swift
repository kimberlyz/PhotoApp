//
//  Transaction.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/4/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class Transaction: NSObject {
    var recipients : [MCPeerID]?
    var assets : [AnyObject]?
    var progress : [NSProgress]?
    
    override init() {
        recipients = [MCPeerID]()
        assets = [PHAsset]()
        progress = [NSProgress]()
    }
}
