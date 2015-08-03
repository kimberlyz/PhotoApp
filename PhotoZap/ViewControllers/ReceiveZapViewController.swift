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
    var receiveCell : ReceiveZapTableViewCell?
    
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
//    func foundPeer() {
//        tableView.reloadData()
//    }
//    
//    func lostPeer() {
//        tableView.reloadData()
//    }
    
    func refreshConnectionStatus() {
        tableView.reloadData()
    }
    
    func invitationWasReceived(fromPeer: String) {
        // empty
    }
    
//    func connectedWithPeer(cell: UITableViewCell) {
//        receiveCell = cell as? ReceiveZapTableViewCell
//        
//        receiveCell!.connectionStatusLabel.text = "Connected"
//        receiveCell!.activityIndicatorView.stopAnimating()
//        tableView.reloadData()
//        
//        receiveCell = nil
//    }
//    
//    func connectingWithPeer(cell: UITableViewCell) {
//        receiveCell = cell as? ReceiveZapTableViewCell
//        
//        receiveCell!.connectionStatusLabel.text = "Connecting"
//        receiveCell!.activityIndicatorView.startAnimating()
//        tableView.reloadData()
//        
//        receiveCell = nil
//    }
//    
//    func notConnectedWithPeer(cell: UITableViewCell) {
//        receiveCell = cell as? ReceiveZapTableViewCell
//        
//        receiveCell!.connectionStatusLabel.text = "Not Connected"
//        receiveCell!.activityIndicatorView.stopAnimating()
//        tableView.reloadData()
//        
//        receiveCell = nil
//    }
//    
//    func connectedWithPeer() {
//    }
//    
//    func notConnectedWithPeer() {
//    }
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
        cell.peer = appDelegate.mpcManager.foundPeers[indexPath.row]
        cell.displayStatus()
        
        
        // cell.peer = appDelegate.mpcManager.foundPeers[indexPath.row]
        // cell.displayStatus
        
//        if receiveCell?.usernameLabel.text == cell.usernameLabel.text {
//            return receiveCell!
//        } else {
//            cell.usernameLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
//            cell.connectionStatusLabel.text = "Not connected"
//
//            return cell
//        }
        
        // if connected, show name and "connected"
        // else, show name, and "not connected"
        
//        cell.usernameLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
//        cell.connectionStatusLabel.text = "Not connected"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! ReceiveZapTableViewCell
        
        if selectedCell.state == .NotConnected {
            let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
            appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
            selectedCell.state = .Connecting
        }
    }

}