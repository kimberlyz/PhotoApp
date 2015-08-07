//
//  NearbyFriendsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/30/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Photos


class NearbyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var assets : [AnyObject] = []
    
    //var transaction : Transaction?
    var isAdvertising: Bool!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.mpcManager.delegate = self
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        appDelegate.mpcManager.foundPeers = [MCPeerID]()
        appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
    }
    
    
    func getAssetUrl(asset: PHAsset, completionHandler: (NSURL!) -> ()) {
        let option = PHContentEditingInputRequestOptions()
        asset.requestContentEditingInputWithOptions(option) { contentEditingInput, info in
            completionHandler(contentEditingInput?.fullSizeImageURL)
        }
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        //var fileURL = NSURL()
        
        println("SendButtonTapped")
        
        let tempDir = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
        
        for asset in (assets/*transaction!.assets*/ as! [PHAsset]) {
            
            //PHContentEditingInputRequestOptions *options = [PHContentEditingInputRequestOptions new];
            
//            let options = PHContentEditingInputRequestOptions()
//            options.canHandleAdjustmentData {
//                (adjustmentData: PHAdjustmentData) -> Bool in
//            }
            
            var fileURL  = NSURL()
            
//            let tempPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
            

            
            var errorFileHandle : NSError?

            
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                var error : NSError?
                
                fileURL = info["PHImageFileURLKey"] as! NSURL
                let fileName = fileURL.lastPathComponent
                let newTempFileURL = tempDir?.URLByAppendingPathComponent(fileName!)
                
                NSFileManager.defaultManager().createFileAtPath(newTempFileURL!.path!, contents: imageData, attributes: nil)
                
//                let fileHandle = NSFileHandle(forWritingToURL: newTempFileURL!, error: &errorFileHandle)
                
//                println("File Handle Error \(errorFileHandle)"
                
                
//                fileHandle?.writeData(imageData)
                //imageData.writeToURL(tempDir!, options: NSDataWritingOptions.DataWritingAtomic, error: &error)
                
                //fileURL = NSURL.fileURLWithPath("/var/mobile/Media/DCIM/105APPLE/IMG_5852.JPG")
                println(newTempFileURL)
                println("yay")
                
                for peer in self.appDelegate.mpcManager.connectedPeers {
                    var progress = self.appDelegate.mpcManager.session.sendResourceAtURL(newTempFileURL, withName: newTempFileURL!.lastPathComponent, toPeer: peer) { (error: NSError?) -> Void in
                        NSLog("Error: \(error)")
                    }
                }

                
                
                /*
                //@IBOutlet var imageURL : UIImageView
                //if let url = fileURL {
                if let data = NSData(contentsOfURL: url){
                //imageURL.contentMode = UIViewContentMode.ScaleAspectFit
                var image = UIImage(data: data)
                }
                //} */
                
                
            }

            
          /*  getAssetUrl(asset) { URL in
                if URL != nil {
                    //fileURL = NSURL()
                    // do something with URL here
                    //fileURL = URL
                    println(URL)
                    for peer in self.appDelegate.mpcManager.connectedPeers {
                        var progress = self.appDelegate.mpcManager.session.sendResourceAtURL(URL, withName: URL.lastPathComponent, toPeer: peer) { (error: NSError?) -> Void in
                            NSLog("Error: \(error)")
                        }
                    }
                }
            } */

            
//            [options setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmentData) {
//                return [adjustmentData.formatIdentifier isEqualToString:AdjustmentFormatIdentifier] && [adjustmentData.formatVersion isEqualToString:@"1.0"];
//                }];
//            
//            asset.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput: PHContentEditingInput, info: NSDictionary) -> Void in
//                fileURL = contentEditingInput.fullSizeImageURL
//            })
            
            
            
            /*
            [asset requestContentEditingInputWithOptions:editOptions
                completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                NSURL *imageURL = contentEditingInput.fullSizeImageURL;
                }]; */
        
            

            

        }

        /*
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        
        //imageData contains the correct data for images and videos
        NSLog(@"info - %@", info);
        NSURL* fileURL = [info objectForKey:@"PHImageFileURLKey"];
        }];
        
        
        PHImageManger
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
        cell.setThumbnailImage(result)
        })
     */
        
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


extension NearbyFriendsViewController: MPCManagerDelegate {
    func refreshConnectionStatus() {
        tableView.reloadData()
    }
    
    
    func invitationWasReceived(fromPeer: String) {
        let alertController = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (action) in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        
        let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.Cancel) { (action) in
            self.appDelegate.mpcManager.invitationHandler(false, nil)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}



extension NearbyFriendsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Waiting for Nearby Friends..."
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.connectedPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeerIDCell") as! UITableViewCell
        
        // if foundPeers is not empty
        cell.textLabel?.text = appDelegate.mpcManager.connectedPeers[indexPath.row].displayName

        return cell
    }
}



