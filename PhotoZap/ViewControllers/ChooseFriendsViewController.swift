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



class ChooseFriendsViewController: UIViewController {

    var assets : [AnyObject] = []
    var friendUsers = [PFUser]()
    var selectedFriendUsers = [PFUser]() /*{
        didSet {
            if selectedFriendUsers.count == 0 {
                sendButton.enabled = false
            } else {
                sendButton.enabled = true
            }
        }
    } */
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
//    var notes: Results<Transaction>! {
//        didSet {
//            // Whenever notes update, update the table view
//            tableView?.reloadData()
//        }
//    }

    
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

        
//        println(reachability)
//        reachability.whenReachable = { reachability in
//            println("Wifi")
//        }

        // Do any additional setup after loading the view.
    }
    
    func delaySend() {
        
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
                
                    realm.write() { // 2
                        realm.add(pendingNotification) // 3
                    }
                    
                    /*
                    let notification = Notification()
                    notification.toUser = friend
                    notification.fromUser = PFUser.currentUser()!
                    
                    notification.imageFile = PFFile(data: imageData)
                    //notification.imageData = imageData
                    
                    notification.pinInBackgroundWithBlock(nil) */
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if selectedFriendUsers.count == 0 {
            SweetAlert().showAlert("No Friends Selected.", subTitle: "Please select some friends before sending photos.", style: AlertStyle.None)
        } else {

        
        // Initial reachability check
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                for var i = 0; i < self.assets.count; i++ {
                    let asset = self.assets[i] as! PHAsset
                    PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                        (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                        
                        for friend in self.selectedFriendUsers {
                            let notification = Notification()
                            notification.toUser = friend
                            notification.fromUser = PFUser.currentUser()!
                            notification.imageFile = PFFile(data: imageData)
                            
                            notification.uploadNotification()
                        }
                    }
                }
                //SweetAlert().showAlert("Photos sent!", subTitle: "", style: AlertStyle.Success)
                SweetAlert().showAlert("Sending photos...", subTitle: "", style: AlertStyle.None)
                self.dismissViewControllerAnimated(true, completion: nil)
                println("Reachable via WiFi")

            } else { /* If there is a celllular network */
                delaySend()
                SweetAlert().showAlert("No Wi-Fi connection.", subTitle: "Putting the photos in the pending section. Will notify you to send them once you get Wi-Fi.", style: AlertStyle.None)
                self.dismissViewControllerAnimated(true, completion: nil)
                println("Reachable via Cellular Network")
            }
        } else { /* Was able to select friends in time, but lost connection */
            delaySend()
            SweetAlert().showAlert("No Connection.", subTitle: "Putting the photos in the pending section. Will notify you to send them once you get Wi-Fi.", style: AlertStyle.None)
            self.dismissViewControllerAnimated(true, completion: nil)
            println("NOOOO")
        }
        }
    }
    
//        
//        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
//            
//            if let image = result {
//                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//                    self.images.insert(image, atIndex: 0)
//                    self.imageView = UIImageView(image: result)
//                    self.tableView.reloadData()
//                }
//            }
//            
//        })
        
        
        
        
        
        /*
        println(reachability)
        
        reachability.whenReachable = { reachability in
            if reachability.isReachableViaWiFi() {
                
                
            } else {
                
                for var i = 0; i < self.assets.count; i++ {
                    let asset = self.assets[i] as! PHAsset
                    PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) {
                        (imageData: NSData!, dataUTI: String!, orientation: UIImageOrientation, info: [NSObject : AnyObject]!) -> Void in
                        
                        for friend in self.selectedFriendUsers {
                            
                            let notification = PFObject(className: "Notification")
                            notification["toUser"] = friend
                            notification["fromUser"] = PFUser.currentUser()!
                            
                            let imageData = imageData
                            let imageFile = PFFile(data: imageData!)
                            notification["image"] = imageFile
                            notification.pinInBackgroundWithBlock(nil)
//                            let photo = PFObject(className: "Photo")
//                            photo["toUser"] = friend
//                            photo["fromUser"] = PFUser.currentUser()!
//                            
//                            let imageData = imageData
//                            let imageFile = PFFile(data: imageData!)
//                            photo["image"] = imageFile
//                            photo.pinInBackgroundWithBlock(nil)
                        
                            
//                            let myTransaction = Transaction()
//                            myTransaction.recipient = friend
//                            myTransaction.imageData = imageData
//                            
//                            let realm = Realm() // 1
//                            realm.write() { // 2
//                                realm.add(myTransaction) // 3
//                            }
                        }
                    }
                }

                
                
                // Do I want to send a photo using cellular data??? Maybe in the future.
                println("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { reachability in
            println("Not reachable")
        }
        
        reachability.startNotifier() */

    
    
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
                //if self.friendUsersCount != self.friendUsers.count {
                    //self.friendUsers = []
                    if let friend1 = friendUsers1 {
                        self.friendUsers += friend1
                    }
                    
                    if let friend2 = friendUsers2 {
                        self.friendUsers += friend2
                    }
                    
//                    // Keep number of friends up-to-date
//                    self.friendUsersCount = self.friendUsers.count
                
                    // Sort friends by their usernames alphabetically
                    self.friendUsers.sort({ $0.username < $1.username })
                    
                    self.tableView.reloadData()
                //}
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