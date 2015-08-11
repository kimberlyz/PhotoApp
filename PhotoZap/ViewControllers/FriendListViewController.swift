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
    var currentFriendUsers: [PFUser] = []
    //var friendUsersCount = -1
    
    var requestingUsers: [PFUser] = []
    var currentRequestingUsers: [PFUser] = []
    //var requestingUsersCount = -1
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    
    // MARK: View Lifecycle
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getFriendRequests()
        getFriendshipForUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.tableView.addSubview(self.refreshControl)
        
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        getFriendshipForUser()
        getFriendRequests()
        
        //self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    func getFriendRequests() {
        // fill the cache of friend requests directed toward the user
        ParseHelper.getFriendRequests(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            self.currentRequestingUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendshipUserA) as! PFUser
            }
            
            if self.currentRequestingUsers.count != self.requestingUsers.count {
                self.requestingUsers = self.currentRequestingUsers
                self.tableView.reloadData()
            }
            
            /*
            if self.requestingUsersCount != self.requestingUsers!.count {

                self.requestingUsersCount = self.requestingUsers!.count
                self.tableView.reloadData()
            } */
            
            //self.tableView.reloadData()
        }
    }

    func getFriendshipForUser() {
        
        var friendUsers1 : [PFUser]?
        var friendUsers2 : [PFUser]?
        
        //self.friendUsers = []
            
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
                
                self.currentFriendUsers = []
                
                if let friend1 = friendUsers1 {
                    self.currentFriendUsers += friend1
                }
                
                if let friend2 = friendUsers2 {
                    self.currentFriendUsers += friend2
                }
                
                // Sort friends by their usernames alphabetically
                self.currentFriendUsers.sort({ $0.username < $1.username })
                
                
                if self.currentFriendUsers.count != self.friendUsers.count {
                    self.friendUsers = self.currentFriendUsers
                    self.tableView.reloadData()
                }
                
                /*
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
                
                
                    // tell refresh control it can stop showing up now
                    if self.refreshControl.refreshing
                    {
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.tableView.reloadData()
                } */
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
            return self.requestingUsers.count
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
            
            let user = self.requestingUsers[indexPath.row]
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            ParseHelper.removeFriendRelationshipFromUser(PFUser.currentUser()!, user2: self.friendUsers[indexPath.row])
            self.friendUsers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}

extension FriendListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && self.requestingUsers.count == 0 {
            return 0
        } else if section == 2 && self.friendUsers.count == 0 {
            return 0
        }
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
        
        removeObjectFromArray(user, &self.requestingUsers)
        
        cell.rejectButton.hidden = true
    }
    
    func cell(cell: FriendRequestTableViewCell, didSelectRejectRequest user: PFUser) {
        
        let alertController = UIAlertController(title: "Reject \(user.username!)'s request?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            //if var requestingUsers = self.requestingUsers {
                ParseHelper.rejectFriendRequest(user, userB: PFUser.currentUser()!)
                //update local cache
                removeObjectFromArray(user, &self.requestingUsers)
                
                //self.requestingUsers = requestingUsers
                
                self.tableView.reloadData()
            //}
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(yesAction)


        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
}


