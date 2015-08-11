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
import TSMessages
import Bond


class NearbyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var assets : [AnyObject] = []
    
    var isAdvertising: Bool!
    
    var status: Bond<MCSessionState>!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate.mpcManager.delegate = self
        //appDelegate.mpcManager.delegate = self
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        
        status = Bond<MCSessionState> () { value in
            self.tableView.reloadData()
            println(self.appDelegate.mpcManager.connectedPeers)
        }
        
        appDelegate.mpcManager.connectionStatus ->> status
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //appDelegate.mpcManager.foundPeers = [MCPeerID]()
        appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if appDelegate.mpcManager.connectedPeers.count == 0 {
            SweetAlert().showAlert("No Friends Connected.", subTitle: "Please make sure you are connected with some friends before sending photos.", style: AlertStyle.None)
        } else {

        
        var i = 1
        for asset in (assets as! [PHAsset]) {
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                
                var error: NSError?
                self.appDelegate.mpcManager.session.sendData(imageData, toPeers: self.appDelegate.mpcManager.session.connectedPeers, withMode: .Reliable, error: &error)
                if error != nil {
                    let ac = UIAlertController(title: "Send error", message: error!.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
        }
            

        //let imageData = UIImagePNGRepresentation(newImage)
        
        // Send it to all peers, ensuring it gets delivered.

        
        // Show an error message if there's a problem.

        /*
        println("SendButtonTapped")
        
        let tempDir = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
        
        var numOfSends = assets.count + self.appDelegate.mpcManager.connectedPeers.count
        var countingNumOfSends = 0
        
        for asset in (assets/*transaction!.assets*/ as! [PHAsset]) {
            

            //var fileURL  = NSURL()
            
//          let tempPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        
            //var errorFileHandle : NSError?

            
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
               
                
                //let imageData = UIImagePNGRepresentation(newImage)
                
                // Send it to all peers, ensuring it gets delivered.
                var error: NSError?
                
                self.appDelegate.mpcManager.session.sendData(imageData, toPeers: self.appDelegate.mpcManager.session.connectedPeers, withMode: .Reliable, error: &error)
                //sendNotification()
                
                // Show an error message if there's a problem.
                if error != nil {
                    let ac = UIAlertController(title: "Send error", message: error!.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }

                
                /*
                fileURL = info["PHImageFileURLKey"] as! NSURL
                let fileName = fileURL.lastPathComponent
                let newTempFileURL = tempDir?.URLByAppendingPathComponent(fileName!)
                
                NSFileManager.defaultManager().createFileAtPath(newTempFileURL!.path!, contents: imageData, attributes: nil)
                
                println(newTempFileURL)
                println("yay")
                
                for peer in self.appDelegate.mpcManager.connectedPeers {
                    var progress = self.appDelegate.mpcManager.session.sendResourceAtURL(newTempFileURL, withName: newTempFileURL!.lastPathComponent, toPeer: peer) { (error: NSError?) -> Void in
                        NSLog("Error: \(error)")
                        TSMessage.showNotificationInViewController(self, title: "\(countingNumOfSends) out of \(numOfSends) images sent!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)
                    }
                } */
            } */
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        SweetAlert().showAlert("Sending Photos...", subTitle: "", style: AlertStyle.None)

        /*
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
        cell.setThumbnailImage(result)
        })
        */
        }
        
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


extension NearbyFriendsViewController: MPCManagerDelegate {
    
    func invitationWasReceived(fromPeer: String) {
        //Chaining alerts with messages on button click
        SweetAlert().showAlert("", subTitle: "\(fromPeer) wants to chat with you.", style: AlertStyle.None, buttonTitle:"Accept", buttonColor:UIColor.colorFromRGB(0x66B2FF) , otherButtonTitle:  "Decline", otherButtonColor: UIColor.colorFromRGB(0x66B2FF)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
                SweetAlert().showAlert("Accepted!", subTitle: "", style: AlertStyle.Success)
            }
            else {
                self.appDelegate.mpcManager.invitationHandler(false, nil)
                SweetAlert().showAlert("Decline!", subTitle: "", style: AlertStyle.Error)
            }
        }
        
        /*
        let alertController = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (action) in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        
        let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.Cancel) { (action) in
            self.appDelegate.mpcManager.invitationHandler(false, nil)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction) */
        
        //self.presentViewController(alertController, animated: true, completion: nil)
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



