//
//  AlbumViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class AlbumViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.delegate = self
        
    }
    
    func takePhoto(sourceViewController: UIViewController) {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, sourceViewController: sourceViewController) { (image: UIImage?) in
            println("Received a callback")

            let photo = Photo()
            photo.image = image
            photo.uploadPhoto()
            
        }
    }
    
    func viewAlbum() {
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, sourceViewController: self) { (image: UIImage?) in
            println("Received a callback. ALBUM")
            
            let photo = Photo()
            photo.image = image
            photo.uploadPhoto()
        }
    }
    

}

// MARK: Tab Bar Delegate

extension AlbumViewController: UITabBarControllerDelegate {

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is CameraViewController) {
            takePhoto(viewController)
            return false
        } else if (viewController is AlbumViewController) {
            viewAlbum()
            return false
        } else {
            return true
        }
    }
}



/*
// Not sure if I need it
override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}



// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/
