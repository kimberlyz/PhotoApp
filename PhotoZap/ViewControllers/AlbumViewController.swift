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
import RealmSwift
import AMPopTip

class AlbumViewController: UIViewController, CTAssetsPickerControllerDelegate {
    
    @IBOutlet weak var WiFiButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var WiFiInfoButton: UIButton!
    
    let reachability = Reachability.reachabilityForInternetConnection()

    var zapBool : Bool?
    
    let infoPopTip = AMPopTip()
    let wiFiInfoPopTip = AMPopTip()
    
    // checks whether you have been notified that you are on wi-fi when app launches
    var firstWarning = true
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        reachability.startNotifier()
        
        let realm = Realm()
        
        if reachability.isReachableViaWiFi(){
            
            WiFiButton.setTitle("Wi-Fi", forState: .Normal)

            if firstWarning && realm.objects(PendingNotification).first != nil  {
                
                SweetAlert().showAlert("You have Wi-Fi!", subTitle: "Would you like to send your pending notifications now?", style: AlertStyle.None, buttonTitle:"No", buttonColor: UIColor.colorFromRGB(0x66B2FF) , otherButtonTitle:  "Yes", otherButtonColor: UIColor.colorFromRGB(0x66B2FF)) { (isOtherButton) -> Void in
                    if isOtherButton == false {
                        self.tabBarController!.selectedIndex = 1
                    }
                }
                
                firstWarning = false
            }
        } else {
            WiFiButton.setTitle("Wi-Fi Delay", forState: .Normal)
        }

    }
    
    @IBAction func zapButtonTapped(sender: AnyObject) {
        zapBool = true
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let sendPhotoAction = UIAlertAction(title: "Send Photo", style: .Default) { (action) in
            self.showAlbum()
        }
        
        let receivePhotoAction = UIAlertAction(title: "Receive Photo", style: .Default) { (action) in
            PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    switch (status)
                    {
                    case .NotDetermined:
                        SweetAlert().showAlert("Can't access photos!", subTitle: "Please enable photo access in your settings.", style: AlertStyle.Warning)
                        
                    case .Restricted:
                        SweetAlert().showAlert("Can't access photos!", subTitle: "Please enable photo access in your settings.", style: AlertStyle.Warning)
                      
                    case .Denied:
                        SweetAlert().showAlert("Can't access photos!", subTitle: "Please enable photo access in your settings.", style: AlertStyle.Warning)
                    case .Authorized:
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let receiveZap = mainStoryboard.instantiateViewControllerWithIdentifier("ReceiveZapNavigation") as! UINavigationController
                        self.presentViewController(receiveZap, animated: true, completion: nil)
                    }
                }
            }
            

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(sendPhotoAction)
        alertController.addAction(receivePhotoAction)
        alertController.addAction(cancelAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func wifiButtonTapped(sender: AnyObject) {
        if reachability.isReachable() {
            zapBool = false
            showAlbum()
        } else {
            SweetAlert().showAlert("No connection.", subTitle: "Sorry, can't send right now.", style: AlertStyle.Error)
        }

    }
    
    @IBAction func infoButton(sender: AnyObject) {
        
        infoPopTip.shouldDismissOnTap = true
        infoPopTip.popoverColor = UIColor.colorFromRGB(0x2664C1)
        infoPopTip.borderColor = UIColor.colorFromRGB(0x2664C1)

        if infoPopTip.isVisible {
            infoPopTip.hide()
        } else {
            infoPopTip.showText("Instantly send photos.\nSome setup required.", direction: .Right, maxWidth: 320, inView: self.view, fromFrame: infoButton.frame)
        }

    }
    @IBAction func wiFiInfoButtonTapped(sender: AnyObject) {
        wiFiInfoPopTip.shouldDismissOnTap = true
        wiFiInfoPopTip.popoverColor = UIColor.colorFromRGB(0x2664C1)
        wiFiInfoPopTip.borderColor = UIColor.colorFromRGB(0x2664C1)
        
        if wiFiInfoPopTip.isVisible {
            wiFiInfoPopTip.hide()
        } else {
            wiFiInfoPopTip.showText("With Wi-Fi: No delay when sending photos.\nNo Wi-Fi, but with cellular connection: Delay.\nNo setup required.", direction: .Down, maxWidth: 320, inView: self.view, fromFrame: WiFiInfoButton.frame)
        }

    }

    
    func showAlbum() {
        
        
        PHPhotoLibrary.requestAuthorization() { (status:PHAuthorizationStatus) in
            dispatch_async(dispatch_get_main_queue()) {
                
                var picker = CTAssetsPickerController()
                picker.delegate = self
                
                // create options for fetching photo only
                var fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)

                // assign options
                picker.assetsFetchOptions = fetchOptions;

                // set default album (Camera Roll)
                //picker.defaultAssetCollection = PHAssetCollectionSubtype.SmartAlbumUserLibrary
                
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
                
                picker.dismissViewControllerAnimated(true, completion: nil)
                
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
                    //let chooseFriends = mainStoryboard.instantiateViewControllerWithIdentifier("ChooseFriendsNavigation") as! UINavigationController
                    let chooseFriends = mainStoryboard.instantiateViewControllerWithIdentifier("ChooseFriendsNavigation") as! UINavigationController
                    (chooseFriends.visibleViewController as! ChooseFriendsViewController).assets = assets
                    self.presentViewController(chooseFriends, animated: true, completion: nil)
                    //(chooseFriends.visibleViewController as! ChooseFriendsViewController).picker = picker
                    //picker.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
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
