//
//  AlbumViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse
import CTAssetsPickerController

class AlbumViewController: UIViewController, CTAssetsPickerControllerDelegate {
    
    
    
    var freshLaunch = true
    override func viewWillAppear(animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
            self.tabBarController!.selectedIndex = 1 // 2nd tab
        }
    }

  //  self.assets = [[NSMutableArray alloc] init]
    
   // var assets:[PHAsset] = []
    var assets : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        
//        // request authorization status
//        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                // update some UI
//            // init picker
//            var picker = CTAssetsPickerController()
//            
//            // set delegate
//            picker.delegate = self
//            
//            // present picker
//            self.presentViewController(picker, animated: true, completion: nil)
//            }
//        }
        
        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
            
            dispatch_async(dispatch_get_main_queue()) {
                var picker = CTAssetsPickerController()
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
            }
        }

    }
    
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.assets = assets
    }
    
//    func assetsPickerController(picker: CTAssetsPickerController, didFinishPickingAssets: [PHAsset]) {
//        picker.dismissViewControllerAnimated(true, completion: nil)
//        self.assets = didFinishPickingAssets
//        // view.reloadData
//    }
  
}