//
//  ReceiveZapViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Bond

class ReceiveZapViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var receiveCell : ReceiveZapTableViewCell?
    
    var status: Bond<MCSessionState>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //appDelegate.mpcManager.delegate = self
        
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        
        
        status = Bond<MCSessionState> () { value in
            // println("State has changed \(value)")
            
                switch value {
                case .Connected:
                    //self.tableView.reloadData()
                    println("value: Connected")
                    
                case .Connecting:
                    println("value: Connecting")
                    
                case .NotConnected:
                    println("Value: Not connected")
                }
            
        
            println(self.appDelegate.mpcManager.connectedPeers)
            self.tableView.reloadData()
        }
        
        appDelegate.mpcManager.connectionStatus ->> status
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //appDelegate.mpcManager.foundPeers = [MCPeerID]()
        appDelegate.mpcManager.browser.stopBrowsingForPeers()
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        cell.peer = appDelegate.mpcManager.foundPeers[indexPath.row]
        cell.displayStatus()
        
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