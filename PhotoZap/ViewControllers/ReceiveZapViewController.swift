//
//  ReceiveZapViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ReceiveZapViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension ReceiveZapViewController: MPCManagerDelegate {
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    
    func invitationWasReceived(fromPeer: String) {
        // empty
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        println("Connected With Peer on the receiving end")
    }
}

extension ReceiveZapViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Searching for Nearby Friends..."
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println(appDelegate.mpcManager.foundPeers.count)
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceiveZapCell") as! ReceiveZapTableViewCell
        
        cell.usernameLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        cell.connectionStatusLabel.text = "Not connected"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
        
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }

}