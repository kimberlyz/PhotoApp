//
//  FriendListViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class FriendListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var friendSectionTitles : [String] = ["Requests", "All Friends"]
    
    // stores all the users that match the current search query
    var users: [PFUser]?
    
    /*
    This is a local cache. It stores all the users this user is friends with.
    It is used to update the UI immediately upon user interaction instead of waiting
    for a server response.
    */
    
    var friendUsers: [PFUser] = []
    var friendUsersCount = -1
    /*{
        didSet {
            /**
            the list of following users may be fetched after the tableView has displayed
            cells. In this case, we reload the data to reflect "following" status
            */
           tableView.reloadData()
        }
    } */
    
    var requestingUsers: [PFUser]? /* {
        didSet {
            tableView.reloadData()
        }
    } */
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // MARK: View Lifecycle
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        ParseHelper.getFriendshipForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFUser] ?? []
            
            self.friendUsers = relations
        } */
        
        getFriendRequests()
        getFriendshipForUser()
    }
    
    func getFriendRequests() {
        // fill the cache of friend requests directed toward the user
        ParseHelper.getFriendRequests(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            self.requestingUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendshipUserA) as! PFUser
            }
            
            self.tableView.reloadData()
        }
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


extension FriendListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendSectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return self.friendUsers?.count ?? 0
        
       // var sectionTitle = friendSectionTitles[section]
        
        if section == 0 {
            return self.requestingUsers?.count ?? 0
        } else {
            return self.friendUsers.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendSectionTitles[section]
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendRequestCell") as! FriendRequestTableViewCell
            
            let user = self.requestingUsers![indexPath.row]
            cell.user = user
            
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
                
            let user = self.friendUsers[indexPath.row]
            cell.user = user
            
            return cell
        }

    }
}

extension FriendListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && (self.requestingUsers == nil || self.requestingUsers?.count == 0) {
            return 0
        } else if section == 2 && self.friendUsers.count == 0 {
            return 0}
        else {
            return 30
        }
    }

}


// MARK: AddFriendTableViewCell Delegate

extension FriendListViewController: FriendRequestTableViewCellDelegate {
    
    func cell(cell: FriendRequestTableViewCell, didSelectConfirmRequest user: PFUser) {
        ParseHelper.confirmFriendRequest(user, userB: PFUser.currentUser()!)
        //update local cache
        self.friendUsers.append(user)
        
        removeObjectFromArray(user, &self.requestingUsers!)
    }
    
    func cell(cell: FriendRequestTableViewCell, didSelectRejectRequest user: PFUser) {
        
        let alertController = UIAlertController(title: "Reject \(user.username!)'s request?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            if var requestingUsers = self.requestingUsers {
                ParseHelper.rejectFriendRequest(user, userB: PFUser.currentUser()!)
                //update local cache
                removeObjectFromArray(user, &requestingUsers)
                
                self.requestingUsers = requestingUsers
                
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(yesAction)


        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
}


