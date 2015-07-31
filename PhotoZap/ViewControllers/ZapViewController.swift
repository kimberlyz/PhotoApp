//
//  ZapViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/24/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class ZapViewController: UIViewController {

    var photoTakingHelper : PhotoTakingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  self.tabBarController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func viewAlbum() {
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            println("Received a callback. ALBUM")
            
            let photo = Photo()
            photo.image = image
            photo.uploadPhoto()
        }
    } */
}


// MARK: Tab Bar Delegate
/*
extension ZapViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is AlbumViewController) {
            viewAlbum()
            return false
        } else {
            return true
        }
    }
} */