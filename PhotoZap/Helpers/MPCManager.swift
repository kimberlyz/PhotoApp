//
//  MPCManager.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/31/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import ConvenienceKit

protocol MPCManagerDelegate {
    func foundPeer()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
}


class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    var foundPeers = [MCPeerID]()
    var connectedPeers = [MCPeerID]()
    var invitationHandler : ((Bool, MCSession!) -> Void)!
    var delegate : MPCManagerDelegate?
    var connectingPeerCell : ReceiveZapTableViewCell?
    
    override init() {
        super.init()
        
        // make the displayName your username in the future
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .Required)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "PhotoZap-mpc12")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "PhotoZap-mpc12")
        advertiser.delegate = self

    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        foundPeers.append(peerID)
        println("Found Peer on receiving end")
        println(foundPeers)
        delegate?.foundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        for (index, aPeer) in enumerate(foundPeers) {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        delegate?.lostPeer()
    }
    
    // If browsing is unable to be performed
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        /*
        var alertController = UIAlertController(title: "Received invitation from \(peerID).", message: "", preferredStyle: .Alert)
        var rejectAction = UIAlertAction(title: "Reject", style: .Cancel, handler: nil)
        var acceptAction = UIAlertAction(title: "Accept", style: .Default) { (action) -> Void in
            
            self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .Required)
            self.mcSession.delegate = self
            
            invitationHandler(true, self.mcSession)
            self.presentViewController(alertController, animated: true, completion: nil)
        } */
        println("received invitation")
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println(error.localizedDescription)
    }
}

extension MPCManager: MCSessionDelegate {
    
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