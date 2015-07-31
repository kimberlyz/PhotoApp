//
//  NearbyFriendsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/30/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NearbyFriendsViewController: UIViewController {

    var nearbyFriends : [MCPeerID]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func reselectPhotosTapped(sender: AnyObject) {
    }

}


extension NearbyFriendsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyFriends?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("nearbyFriendsCell") as! UITableViewCell
        
        cell.textLabel!.text = nearbyFriends![indexPath.row].displayName

        return cell
    }
    
}

