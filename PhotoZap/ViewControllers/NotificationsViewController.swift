//
//  NotificationsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/4/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notificationsSectionTitles : [String] = ["Received", "Pending"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return notificationsSectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return self.friendUsers?.count ?? 0
    
//        
//        if section == 0 {
//            return self.requestingUsers?.count ?? 0
//        } else {
//            return self.friendUsers.count ?? 0
//        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return notificationsSectionTitles[section]
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
        
        cell.usernameLabel.text = "Merp"

        return cell
        
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCellWithIdentifier("FriendRequestCell") as! FriendRequestTableViewCell
//            
//            let user = self.requestingUsers![indexPath.row]
//            cell.user = user
//            
//            cell.delegate = self
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCellWithIdentifier("FriendListCell") as! FriendListTableViewCell
//            
//            let user = self.friendUsers[indexPath.row]
//            cell.user = user
//            
//            return cell
//        }
        
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.Delete {
//            ParseHelper.removeFriendRelationshipFromUser(PFUser.currentUser()!, user2: self.friendUsers[indexPath.row])
//            self.friendUsers.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//        }
//    }
}

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
        
//        if section == 0 && (self.requestingUsers == nil || self.requestingUsers?.count == 0) {
//            return 0
//        } else if section == 2 && self.friendUsers.count == 0 {
//            return 0}
//        else {
//            return 30
//        }
    }
    
}