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
    
    var transaction : Transaction?
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
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        var fileURL : NSURL?
        
        println("SendButtonTapped")
        
        for asset in (transaction!.assets as! [PHAsset]) {
        
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                fileURL = info["PHImageFileURLKey"] as? NSURL
                println("yay")
            }
            
            for peer in appDelegate.mpcManager.connectedPeers {
                var progress = appDelegate.mpcManager.session.sendResourceAtURL(fileURL, withName: fileURL?.lastPathComponent, toPeer: peer) { (error: NSError?) -> Void in
                    NSLog("Error: \(error)")
                }
            }
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



