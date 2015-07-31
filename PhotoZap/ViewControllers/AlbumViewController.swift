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
    
    var assets : [AnyObject] = []
    var zapBool : Bool?
    
    var freshLaunch = true
    override func viewWillAppear(animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
            self.tabBarController!.selectedIndex = 1 // 2nd tab
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
  /*
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        nearbyFriends = NearbyFriendsViewController()
    } */
    
    @IBAction func zapButtonTapped(sender: AnyObject) {
        zapBool = true
        showAlbum()
    }
    
    @IBAction func wifiButtonTapped(sender: AnyObject) {
        zapBool = false
        showAlbum()
    }
    
    
    func showAlbum() {
        
        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue()) {
                var picker = CTAssetsPickerController()
                picker.delegate = self
                //self.presentViewController(picker, animated: true, completion: nil)
                
                
                // create options for fetching photo only
                var fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)

                // assign options
                picker.assetsFetchOptions = fetchOptions;

                // set default album (Camera Roll)
                picker.defaultAssetCollection = PHAssetCollectionSubtype.SmartAlbumUserLibrary
                
                // hide cancel button;
                // picker.showsCancelButton = false
                
                // make done button enable even without selection
                picker.alwaysEnableDoneButton = true
                
                // present picker
                self.presentViewController(picker, animated: true, completion: nil)
            }
        }

    }
}

extension AlbumViewController : CTAssetsPickerControllerDelegate {
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        
        // If no photos were selected, dismiss CTAssetsPickerController
        if assets.count == 0 {
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        // If photos were selected, check for the method of sending
        else {
            if let zapBool = zapBool {
                // Do Wi-Fi Direct
                if zapBool {
                    picker.dismissViewControllerAnimated(true, completion: nil)
                    self.assets = assets
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let nearbyFriends = mainStoryboard.instantiateViewControllerWithIdentifier("NearbyFriendsNavigation") as! UINavigationController
                    self.presentViewController(nearbyFriends, animated: true, completion: nil)
                }
                // Do Wi-Fi Delay
                else {
                    
                     println("Do Wi-Fi Delay")
                }
            }
        }
        // tableView.reloadData
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: PHAsset!) -> Bool {
        let max = 10
        
        if picker.selectedAssets.count >= max {
            var alert = UIAlertController(title: "Attention", message: "Please select not more than \(max) assets", preferredStyle: .Alert)
            var action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(action)
            picker.presentViewController(alert, animated: true, completion: nil)
        }
        
        return picker.selectedAssets.count < max
    }
}
