//
//  ChooseFriendsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit
import Reachability

class ChooseFriendsViewController: UIViewController {

    var friendUsers = [PFUser]()
    var selectedFriendUsers = [PFUser]()
    var friendUsersCount = -1
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFriendshipForUser()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        let reachability = Reachability.reachabilityForInternetConnection()
        
        reachability.whenReachable = { reachability in
            if reachability.isReachableViaWiFi() {
                println("Reachable via WiFi")
            } else {
                // Do I want to send a photo using cellular data??? Maybe in the future.
                println("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { reachability in
            println("Not reachable")
        }
        
        reachability.startNotifier()
    }
    
    
    func getFriendshipForUser() {
        
        var friendUsers1 : [PFUser]?
        var friendUsers2 : [PFUser]?
        
        ParseHelper.getFriendshipAsUserB(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            friendUsers1 = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendshipUserA) as! PFUser
            }
            
            ParseHelper.getFriendshipAsUserA(PFUser.currentUser()!) {
                (results: [AnyObject]?, error: NSError?) -> Void in
                let relations = results as? [PFObject] ?? []
                
                friendUsers2 = relations.map {
                    $0.objectForKey(ParseHelper.ParseFriendshipUserB) as! PFUser
                }
                
                // If your list of friends has changed (# of friends has changed),
                // add the friends to the array and reload the tableView
                if self.friendUsersCount != self.friendUsers.count {
                    self.friendUsers = []
                    if let friend1 = friendUsers1 {
                        self.friendUsers += friend1
                    }
                    
                    if let friend2 = friendUsers2 {
                        self.friendUsers += friend2
                    }
                    
                    // Keep number of friends up-to-date
                    self.friendUsersCount = self.friendUsers.count
                    
                    // Sort friends by their usernames alphabetically
                    self.friendUsers.sort({ $0.username < $1.username })
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
}


extension ChooseFriendsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseFriendsCell") as! ChooseFriendsTableViewCell
        
        // if foundPeers is not empty
        let user = friendUsers[indexPath.row]
        cell.user = user
        

        // check if current user is already sent a friend request to the displayed user
        // change button appearance based on result
        cell.canSelect = !contains(selectedFriendUsers, user)

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! ChooseFriendsTableViewCell
        
        if selectedCell.canSelect == true {
            selectedCell.canSelect = false
            selectedFriendUsers.append(selectedCell.user!)
        } else {
            selectedCell.canSelect = true
            removeObjectFromArray(selectedCell.user!, &selectedFriendUsers)
        }
    }
}