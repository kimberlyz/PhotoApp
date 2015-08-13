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
    
    @NSManaged var imageFile : PFFile?
    @NSManaged var toUser: PFUser?
    @NSManaged var fromUser: PFUser?
    
    var imageData: NSData?
    var imagePic: UIImage?
    
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
        
        let acl = PFACL()
        acl.setReadAccess(true, forUser: toUser!)
        acl.setReadAccess(true, forUser: fromUser!)
        acl.setWriteAccess(true, forUser: fromUser!)
        acl.setWriteAccess(true, forUser: toUser!)
        
        self.ACL = acl
        
        //imageFile = PFFile(data: imageData!)
        
        println("hello: \(imageFile)")
        imageFile!.saveInBackgroundWithBlock(nil)
        
        saveInBackgroundWithBlock(nil)
    }
}
