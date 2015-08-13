//
//  PendingNotification.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/7/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import RealmSwift

class PendingNotification: Object {
    
    dynamic var toUserObjectId : String = ""
    dynamic var toUserUsername : String = ""
    dynamic var imageData : NSData = NSData()
    
}