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
import ReachabilitySwift
//import RealmSwift

class AlbumViewController: UIViewController, CTAssetsPickerControllerDelegate {
    
    //var assets : [AnyObject] = []
    //var transaction : Transaction?
    
    
    let reachability = Reachability.reachabilityForInternetConnection()

    var zapBool : Bool?
    
//    var transactions: Results<Transaction>! {
//        didSet {
//            // Whenever notes update, update the table view
//            println("Transaction assigned")
//        }
//    }
    
    /*
    var freshLaunch = true
    override func viewWillAppear(animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
            self.tabBarController!.selectedIndex = 1 // 2nd tab
        }
    } */

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let query = PFQuery(className:"Notification")
//        query.fromLocalDatastore()
//        
//        query.findObjectsInBackgroundWithBlock({
//            (results: [AnyObject]?, error: NSError?) -> Void in
//            let relations = results as? [Notification] ?? []
//            
//            for what in relations {
//                what.unpinInBackground()
//                println("hi")
//            }
//        })
        
//
        reachability.startNotifier()
//        let realm = Realm()
//        transactions = realm.objects(Transaction)

    }
  /*
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        nearbyFriends = NearbyFriendsViewController()
    } */
    
    @IBAction func zapButtonTapped(sender: AnyObject) {
        zapBool = true
        
        let alertController = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .ActionSheet)
        let sendPhotoAction = UIAlertAction(title: "Send Photo", style: .Default) { (action) in
            self.showAlbum()
        }
        
        let receivePhotoAction = UIAlertAction(title: "Receive Photo", style: .Default) { (action) in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let receiveZap = mainStoryboard.instantiateViewControllerWithIdentifier("ReceiveZapNavigation") as! UINavigationController
            self.presentViewController(receiveZap, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(sendPhotoAction)
        alertController.addAction(receivePhotoAction)
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
            
        // showAlbum()
    }
    
    @IBAction func wifiButtonTapped(sender: AnyObject) {
        if reachability.isReachable() {
            zapBool = false
            showAlbum()
        } else {
            SweetAlert().showAlert("No connection.", subTitle: "Sorry, can't send right now.", style: AlertStyle.Error)
        }

    }
    
    
    func showAlbum() {
        
        
        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue()) {
                
                switch (status)
                {
                case .Authorized:
                    println("Authorized")
                    
                case .Denied:
                    println("Denied")
                case .Restricted:
                    println("Restricted")
                    
                case .NotDetermined:
                    println("Not determined")
                    
                }
                
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
                
                //transaction = Transaction()
                
                picker.dismissViewControllerAnimated(true, completion: nil)
                //transaction!.assets = assets
                //self.assets = assets
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Do Wi-Fi Direct
                if zapBool {
                    let nearbyFriends = mainStoryboard.instantiateViewControllerWithIdentifier("NearbyFriendsNavigation") as! UINavigationController
                    (nearbyFriends.visibleViewController as! NearbyFriendsViewController).assets = assets
                    self.presentViewController(nearbyFriends, animated: true, completion: nil)
                    //self.performSegueWithIdentifier("NearbyFriendsNavigation", sender: self)
                }
                // Do Wi-Fi Delay
                else {
                    let chooseFriends = mainStoryboard.instantiateViewControllerWithIdentifier("ChooseFriendsNavigation") as! UINavigationController
                    (chooseFriends.visibleViewController as! ChooseFriendsViewController).assets = assets
                    self.presentViewController(chooseFriends, animated: true, completion: nil)
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
