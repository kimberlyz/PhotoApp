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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // fill the cache of a user's friends
        ParseHelper.getFriendUsersForUser(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            // use map to extract the User from a Friend Object
            self.friendUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendToUser) as! PFUser
            }
            
            /*
            if let error = error {
            // Call the default error handler in case of an error
            ErrorHandling.defaultErrorHandler(error)
            }
            */
        }
    }

}

extension FriendListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendUsers?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
        
        if let friendUsers = self.friendUsers {
            let friendUser = friendUsers[indexPath.row]
            cell.user = friendUser
        }
        return cell
    }
}
/*
extension FriendListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
*/
