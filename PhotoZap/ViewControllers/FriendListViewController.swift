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
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // MARK: View Lifecycle
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // fill the cache of a user's friends
        ParseHelper.getFriendshipForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            // Does this work?
            self.friendUsers = relations as? [PFUser] ?? []
            
            /*
            if let error = error {
            // Call the default error handler in case of an error
            ErrorHandling.defaultErrorHandler(error)
            }
            */
        }
    } */

}

extension FriendListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return self.friendUsers?.count ?? 0
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
     //   let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
        
       // let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        /*
        if let friendUsers = self.friendUsers {
            let friendUser = friendUsers[indexPath.row]
            cell.user = friendUser
        } */
     //   cell.usernameLabel.text = "Friend"
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
            cell.usernameLabel.text = "Friend Requests Here"
            return cell
        } else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
            cell.usernameLabel.text = "Pending Friends Here"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
            cell.usernameLabel.text = "All Friends Here"
            return cell
        }
    }
}

extension FriendListViewController: UITableViewDelegate {
    
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
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    

    /*
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    } */

}

