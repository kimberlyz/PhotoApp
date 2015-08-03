//
//  NearbyFriendsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/30/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class NearbyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var isAdvertising: Bool!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers() */
        
        appDelegate.mpcManager.delegate = self
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //appDelegate.mpcManager.browser.stopBrowsingForPeers()
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}


extension NearbyFriendsViewController: MPCManagerDelegate {
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
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
        
        
        // What?
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        println("Connected With Peer on the sending end")
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



