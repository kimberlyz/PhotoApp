//
//  Photo.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import Parse

class Photo : PFObject, PFSubclassing {
    
    //@NSManaged var imageFile: PFFile?
    @NSManaged var image : PFObject?
    @NSManaged var toUser: PFUser?
    @NSManaged var fromUser: PFUser?
    
    //var imageData: UIImage?
    var imageData: NSData?
    var photoUploadTask : UIBackgroundTaskIdentifier?
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Photo"
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
    
    func uploadPhoto() {
        //let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imageFile = PFFile(data: imageData!)
        imageFile.saveInBackgroundWithBlock(nil)
        
        let imageObject = PFObject(className: "Image")
        imageObject.setObject(imageFile, forKey: "imageFile")
        
        
//        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
//            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
//        }
//        
//        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            
//            if let error = error {
//                ErrorHandling.defaultErrorHandler(error)
//            }
//            
//            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
//        }
        
        // any uploaded post should be associated with the current user
        fromUser = PFUser.currentUser()
        self.image = imageObject
        saveInBackgroundWithBlock(nil)
    }
}
