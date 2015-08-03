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
    
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var foundPeers = [MCPeerID]()
    var connectedPeers = [MCPeerID]()
    var invitationHandler : ((Bool, MCSession!) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make the displayName your username in the future
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "PhotoZap-mpc12")
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension ReceiveZapViewController: MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        foundPeers.append(peerID)
        println("Found Peer on receiving end")
        println(foundPeers)
        tableView.reloadData()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        for (index, aPeer) in enumerate(foundPeers) {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        tableView.reloadData()
    }
    
    // If browsing is unable to be performed
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
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

extension ReceiveZapViewController: MCSessionDelegate {
    
    /** Called when a user connects or disconnects from our session
    Is someone connecting, are they now connected, or have they just disconnected?
    */
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        switch state {
            
        case MCSessionState.Connected:
            println("Connected: \(peerID.displayName)")
            connectedPeers.append(peerID)
            println(connectedPeers)
            if (connectingPeerCell != nil){
                connectingPeerCell!.connectionStatusLabel.text = "Connected"
                connectingPeerCell!.activityIndicatorView.stopAnimating()
                connectingPeerCell = nil
            }
            
        case MCSessionState.Connecting:
            println("Connecting: \(peerID.displayName)")
            if (connectingPeerCell != nil) {
                
                var view = connectingPeerCell?.superview
                
                connectingPeerCell!.connectionStatusLabel.text = "Connecting"
                connectingPeerCell!.activityIndicatorView.startAnimating()
            }
            
            
        case MCSessionState.NotConnected:
            println("Not Connected: \(peerID.displayName)")
            println(connectedPeers)
            if connectedPeers.count != 0 {
                removeObjectFromArray(peerID, &connectedPeers)
            }
        }
        
    }
    
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
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
        return foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceiveZapCell") as! ReceiveZapTableViewCell
        
        cell.usernameLabel.text = foundPeers[indexPath.row].displayName
        cell.connectionStatusLabel.text = "Not connected"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! ReceiveZapTableViewCell
        appDelegate.mpcManager.connectingPeerCell = selectedCell
        
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }

}