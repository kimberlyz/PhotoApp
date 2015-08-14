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
import AMPopTip
import Mixpanel

class NearbyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var infoButton: UIButton!
    
    let infoPopTip = AMPopTip()
    var assets : [AnyObject] = []
    
    var isAdvertising: Bool!
    
    var status: Bond<MCSessionState>!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        
        appDelegate.mpcManager.delegate = self
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        
        status = Bond<MCSessionState> () { value in
            self.tableView.reloadData()
            //println(self.appDelegate.mpcManager.connectedPeers)
        }
        
        appDelegate.mpcManager.connectionStatus ->> status
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if appDelegate.mpcManager.connectedPeers.count == 0 {
            SweetAlert().showAlert("No Friends Connected.", subTitle: "Please make sure you are connected with some friends before sending photos.", style: AlertStyle.None)
        } else {
            Mixpanel.sharedInstance().track("Zap sender", properties: ["Button": "Sent photos"])
        
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

            }
        
            self.dismissViewControllerAnimated(true, completion: nil)
            SweetAlert().showAlert("Sending Photos...", subTitle: "", style: AlertStyle.None)
        }
        
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        Mixpanel.sharedInstance().track("Zap sender", properties: ["Button": "Cancel"])
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        infoPopTip.shouldDismissOnTap = true
        infoPopTip.popoverColor = UIColor.colorFromRGB(0x2664C1)
        infoPopTip.borderColor = UIColor.colorFromRGB(0x2664C1)
        
        if infoPopTip.isVisible {
            infoPopTip.hide()
        } else {
            Mixpanel.sharedInstance().track("Zap sender", properties: ["Button": "Info"])
            infoPopTip.showText("Your friends need to:\n1. Be nearby\n2. Open the app\n3. Tap on the zap button\n4. Tap on the receive photo button\n5. Tap on your username to connect", direction: .Down, maxWidth: 320, inView: self.view, fromFrame: infoButton.frame)
        }
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



