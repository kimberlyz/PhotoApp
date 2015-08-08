//
//  PendingNotification.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/7/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import RealmSwift
import Parse

class PendingNotification: Object {
    
    dynamic var toUser : PFUser = PFUser()
    dynamic var imageData : NSData = NSData()
    
    //    var recipients : [MCPeerID]?
    //    var assets : [AnyObject]?
    //    var progress : [NSProgress]?
    //
    //    override init() {
    //        recipients = [MCPeerID]()
    //        assets = [PHAsset]()
    //        progress = [NSProgress]()
    //    }
}