//
//  NearbyFriendsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/30/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class NearbyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource/*, MPCManagerDelegate */{

    @IBOutlet weak var tableView: UITableView!
    
    var isAdvertising: Bool!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers() */
        
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appDelegate.mpcManager.browser.stopBrowsingForPeers()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func reselectPhotosTapped(sender: AnyObject) {
    }

}

/*
extension NearbyFriendsViewController: MPCManagerDelegate {
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
} */



extension NearbyFriendsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeerIDCell") as! UITableViewCell
        
        // if foundPeers is not empty
        cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName

        return cell
    }
}

