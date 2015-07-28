//
//  FriendListViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import Parse

class FriendListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var friendSectionTitles : [String] = ["Requests", "Pending", "All Friends"]
    
    // stores all the users that match the current search query
    var users: [PFUser]?
    
    /*
    This is a local cache. It stores all the users this user is friends with.
    It is used to update the UI immediately upon user interaction instead of waiting
    for a server response.
    */
    
    var friendUsers: [PFUser]? {
        didSet {
            /**
            the list of following users may be fetched after the tableView has displayed
            cells. In this case, we reload the data to reflect "following" status
            */
            tableView.reloadData()
        }
    }
    
    var pendingUsers: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var requestingUsers: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        
        getFriendshipForUser()

        
        println(self.friendUsers)
        
        
    }
    
    func getFriendshipForUser() {
        // fill the cache of a user's friends
        ParseHelper.getFriendshipAsUserA(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            // use map to extract the User from a Follow object
            self.friendUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendshipUserB) as! PFUser
            }
            /*
            if let error = error {
            // Call the default error handler in case of an Error
            ErrorHandling.defaultErrorHandler(error)
            } */
        }
        
        ParseHelper.getFriendshipAsUserB(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            // use map to extract the User from a Follow object
            self.friendUsers?.extend(relations.map {
                $0.objectForKey(ParseHelper.ParseFriendshipUserB) as! PFUser
                })
            
            /*
            if let error = error {
            // Call the default error handler in case of an Error
            ErrorHandling.defaultErrorHandler(error)
            } */
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
        } else if section == 1 {
            return self.pendingUsers?.count ?? 0
        } else {
            return self.friendUsers?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendSectionTitles[section]
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
            cell.usernameLabel.text = "Friend Requests Here"
            
            let user = self.requestingUsers![indexPath.row]
            cell.user = user
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
            cell.usernameLabel.text = "Pending Friends Here"
            
            let user = self.pendingUsers![indexPath.row]
            cell.user = user
            
            return cell
        } else { /*
            if self.friendUsers == nil || self.friendUsers?.count == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
                cell.usernameLabel.text = "No friends."
                
                return cell
            } else { */
                let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
                cell.usernameLabel.text = "All Friends Here"
                
                let user = self.friendUsers![indexPath.row]
                cell.user = user
                return cell
          //  }
        }

    }
}

extension FriendListViewController: UITableViewDelegate {
    /*
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("FriendHeader") as! FriendHeaderView

        if section == 0 {
            headerCell.headerLabel.text = "Requests"
        } else if section == 1 {
            headerCell.headerLabel.text = "Pending"
        } else {
            headerCell.headerLabel.text = "All Friends"
        }
        
        return headerCell
    } */
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && (self.requestingUsers == nil || self.requestingUsers?.count == 0) {
            return 0
        } else if section == 1 && (self.pendingUsers == nil || self.pendingUsers?.count == 0) {
            return 0
        } else if section == 2 && (self.friendUsers == nil || self.friendUsers?.count == 0) {
            return 0}
        else {
            return 30
        }
    }
    

    /*
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    } */

}

