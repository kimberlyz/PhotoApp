//
//  Notification.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/5/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import Parse

class Notification : PFObject, PFSubclassing {
    
    @NSManaged var image : PFObject?
    @NSManaged var toUser: PFUser?
    @NSManaged var fromUser: PFUser?
    
    var imageData: NSData?
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Notification"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadNotification() {

        let imageFile = PFFile(data: imageData!)
        imageFile.saveInBackgroundWithBlock(nil)
        
        let imageObject = PFObject(className: "Image")
        imageObject.setObject(imageFile, forKey: "imageFile")
        
        fromUser = PFUser.currentUser()
        self.image = imageObject
        saveInBackgroundWithBlock(nil)
    }
}
