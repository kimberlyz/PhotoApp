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
import Photos
import RealmSwift
import ReachabilitySwift
import Mixpanel
//import CTAssetsPickerController

class ChooseFriendsViewController: UIViewController {

    var assets : [AnyObject] = []
    var friendUsers = [PFUser]()
    var selectedFriendUsers = [PFUser]()
    
    //var picker : CTAssetsPickerController?
    
    let reachability = Reachability.reachabilityForInternetConnection()

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reachability.startNotifier()
        
        friendUsers = [PFUser]()
        
        if reachability.isReachable() {
            getFriendshipForUser()
        } else {
            SweetAlert().showAlert("No connection.", subTitle: "Sorry, can't send right now.", style: AlertStyle.Error)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func delaySend() {
        Mixpanel.sharedInstance().track("Wi-Fi Choose Friends", properties: ["Method": "Wi-Fi Delay"])
        
        let realm = Realm()
        
        for var i = 0; i < self.assets.count; i++ {
            let asset = self.assets[i] as! PHAsset
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                
                for friend in self.selectedFriendUsers {
                    
                    let pendingNotification = PendingNotification()
                    pendingNotification.toUserObjectId = friend.objectId!
                    pendingNotification.toUserUsername = friend.username!
                    pendingNotification.imageData = imageData
                
                    realm.write() {
                        realm.add(pendingNotification)
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        Mixpanel.sharedInstance().track("Wi-Fi Choose Friends", properties: ["Button": "Cancel"])
    }

    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if selectedFriendUsers.count == 0 {
            SweetAlert().showAlert("No Friends Selected.", subTitle: "Please select some friends before sending photos.", style: AlertStyle.None)
        } else {

        // Initial reachability check
            if reachability.isReachable() {
                if reachability.isReachableViaWiFi() {
                    Mixpanel.sharedInstance().track("Wi-Fi Choose Friends", properties: ["Method": "Wi-Fi"])
                    
                    for var i = 0; i < self.assets.count; i++ {
                        let asset = self.assets[i] as! PHAsset
                        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                            (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                        
                            for friend in self.selectedFriendUsers {
                                let notification = Notification()
                                notification.toUser = friend
                                notification.fromUser = PFUser.currentUser()!
                                notification.imageFile = PFFile(data: imageData)
                            
                                notification.uploadNotification { (success: Bool, error: NSError?) -> Void in
                                    if error != nil {
                                        let realm = Realm()
                                        
                                        let pendingNotification = PendingNotification()
                                        pendingNotification.toUserObjectId = friend.objectId!
                                        pendingNotification.toUserUsername = friend.username!
                                        pendingNotification.imageData = imageData
                                        
                                        realm.write() {
                                            realm.add(pendingNotification)
                                        }
                                        
                                        SweetAlert().showAlert("Upload failed.", subTitle: "Putting the photo in the pending section.", style: .Warning)
                                        Mixpanel.sharedInstance().track("Failed send", properties: ["Method": "Wi-Fi"])
                                        
                                    } else {
                                        Mixpanel.sharedInstance().track("Successful send", properties: ["Method": "Wi-Fi"])
                                    }
                                }
                            }
                        }
                    }
                    //SweetAlert().showAlert("Photos sent!", subTitle: "", style: AlertStyle.Success)
                    SweetAlert().showAlert("Sending photos...", subTitle: "", style: AlertStyle.None)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    //picker!.dismissViewControllerAnimated(false, completion: nil)

                } else { /* If there is a cellular network */
                    delaySend()
                    SweetAlert().showAlert("No Wi-Fi connection.", subTitle: "Putting the photos in the pending section. Will notify you to send them once you get Wi-Fi.", style: AlertStyle.None)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else { /* Was able to select friends in time, but lost connection */
                delaySend()
                SweetAlert().showAlert("No Connection.", subTitle: "Putting the photos in the pending section. Will notify you to send them once you get Wi-Fi.", style: AlertStyle.None)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    func getFriendshipForUser() {
        
        var friendUsers1 : [PFUser]?
        var friendUsers2 : [PFUser]?
        
        ParseHelper.getFriendshipAsUserB(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ParseErrorHandlingController.handleParseError(error)
            }
            
            let relations = results as? [PFObject] ?? []
            
            friendUsers1 = relations.map {
                $0.objectForKey(ParseHelper.ParseFriendshipUserA) as! PFUser
            }
            
            ParseHelper.getFriendshipAsUserA(PFUser.currentUser()!) {
                (results: [AnyObject]?, error: NSError?) -> Void in
                if let error = error {
                    ParseErrorHandlingController.handleParseError(error)
                }
                
                let relations = results as? [PFObject] ?? []
                
                friendUsers2 = relations.map {
                    $0.objectForKey(ParseHelper.ParseFriendshipUserB) as! PFUser
                }

                if let friend1 = friendUsers1 {
                    self.friendUsers += friend1
                }
                    
                if let friend2 = friendUsers2 {
                    self.friendUsers += friend2
                }

                self.friendUsers.sort({ $0.username < $1.username })
                    
                self.tableView.reloadData()
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