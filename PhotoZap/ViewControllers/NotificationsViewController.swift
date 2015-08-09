//
//  NotificationsViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/4/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import ConvenienceKit
import Photos
import Parse
import TSMessages
import ReachabilitySwift
import MultipeerConnectivity

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var friendPeerID: MCPeerID?
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var notifications = [Notification]()
    var pendingNotifications = [Notification]()
    
    var images = [UIImage]()
    var delayedNotifications = [Notification]()
    
    // UHHH
    var senderInfo = [AnyObject]()  // var dict: [String: AnyObject]
    
    var notificationsSectionTitles : [String] = ["Received", "", "Pending"]
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotifications()
        getDelayedNotifications()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        reachability.startNotifier()
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func getNotifications() {
        ParseHelper.getNotifications(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [Notification] ?? []
            
            self.notifications = relations
            self.tableView.reloadData()
        }
    }
    
    func getDelayedNotifications() {
        
        let query = Notification.query()
        query!.fromLocalDatastore()

        query!.findObjectsInBackgroundWithBlock({
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [Notification] ?? []
            
            self.pendingNotifications = relations
            
            for what in self.pendingNotifications {
                println(what)
                
            }
        })
        
    }


}

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return notificationsSectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.images.count
            //return self.notifications.count
        } else if section == 1 {
            return self.notifications.count
        } else {
            return self.pendingNotifications.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return notificationsSectionTitles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
//        
//        let notificationObject = self.notifications[indexPath.row]
//        
//        cell.fromUser = notificationObject.objectForKey(ParseHelper.ParseNotificationFromUser) as? PFUser
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ZapCell") as! ZapTableViewCell
            
            if let friendPeerID = friendPeerID {
                cell.usernameLabel.text = friendPeerID.displayName
                cell.photo = self.images[indexPath.row]
            }

            //let notificationObject = self.notifications[indexPath.row]
            //cell.fromUser = notificationObject.objectForKey(ParseHelper.ParseNotificationFromUser) as? PFUser

            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
            
            let notificationObject = self.notifications[indexPath.row]
            cell.fromUser = notificationObject.objectForKey(ParseHelper.ParseNotificationFromUser) as? PFUser
            
            //var image = UIImage(named: ")
            
            return cell
        } else {
            // Some wonky logic....
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
            
            let pendingNotificationObject = self.pendingNotifications[indexPath.row]
            
            //cell.fromUser = PFUser.currentUser()!
            var pendingImage = UIImage(named: "PendingImage.png")
            
            cell.toUser = pendingNotificationObject.objectForKey(ParseHelper.ParseNotificationToUser) as? PFUser
            cell.imageView!.image = pendingImage
            
            //FromUser is not set when it is pending? OH wait no. I should set it. But maybe only set it when I send it?
            //Or just add a variable. IsPending = true or false
            // cell.fromUser = notificationObject.objectForKey(ParseHelper.ParseNotificationFromUser) as? PFUser
            
            return cell
        }
        
     }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! ZapTableViewCell
            
            // if photo has been downloaded, download the image. Otherwise, don't do anything.
            if selectedCell.photo != nil {
                UIImageWriteToSavedPhotosAlbum(selectedCell.photo, nil, nil, nil)
                TSMessage.showNotificationInViewController(self, title: "Image saved!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)
                
                let cellIndexPath = self.tableView.indexPathForCell(selectedCell)
                self.images.removeAtIndex(cellIndexPath!.row)
            }
            
        } else if indexPath.section == 1 { /* Is an image sent from Wi-Fi */
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationsTableViewCell
            
            let notificationObject = self.notifications[indexPath.row]
            
            // Image hasn't been downloaded yet, so download it
            if notificationObject.imagePic == nil {
                //let query = PFQuery(className: ParseNotificationClass)
                
                let query = PFQuery(className:ParseHelper.ParseNotificationClass)
                let notificationObjectId = notificationObject.objectId
                
                query.getObjectInBackgroundWithId(notificationObjectId!) {
                    (notificationObj: PFObject?, error: NSError?) -> Void in
                    if error == nil && notificationObj != nil {
                        println(notificationObj)
                        
                        let imageFile = notificationObj!.objectForKey(ParseHelper.ParseNotificationImageFile) as! PFFile
                        notificationObject.imageFile = imageFile
                        
                        selectedCell.activityIndicator.startAnimating()
                        
                        imageFile.getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            if (error == nil) {
                                if let imageData = imageData {
                                    //let image = UIImage(data: imageData, scale:1.0)!
                                    
                                    let image = UIImage(data: imageData)
                                    notificationObject.imagePic = image
                                    
                                    selectedCell.notificationsImageView.image = image
                                    
                                    selectedCell.activityIndicator.stopAnimating()
                                    
                                    self.tableView.reloadData()
                                }
                                
                            }
                        }
                    } else {
                        println("error")
                    }
                }
            } else { /* If image is already downloaded, save the image */
                TSMessage.showNotificationInViewController(self, title: "Image saved!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)
                
                UIImageWriteToSavedPhotosAlbum(notificationObject.imagePic, nil, nil, nil)
                println("Image Saved")
                
                let cellIndexPath = self.tableView.indexPathForCell(selectedCell)
                self.notifications.removeAtIndex(cellIndexPath!.row)
                
                
                let query = PFQuery(className:ParseHelper.ParseNotificationClass)
                let notificationObjectId = notificationObject.objectId
                
                query.getObjectInBackgroundWithId(notificationObjectId!) {
                    (notificationObj: PFObject?, error: NSError?) -> Void in
                    if error == nil && notificationObj != nil {
                        notificationObj!.deleteInBackgroundWithBlock(nil)
                    } else {
                        println("error")
                    }
                }

                self.tableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        } else { /* Pending cell */
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
            
            let pendingNotificationObject = self.pendingNotifications[indexPath.row]

            /*pendingNotificationObject.saveInBackgroundWithBlock(){ (result, error) in
                if error != nil {
                    println(result)
                }

            } */
            
            //pendingNotificationObject.unpinInBackgroundWithBlock(nil)
            
            // Initial reachability check
            if reachability.isReachable() {
                if reachability.isReachableViaWiFi() {
                    
//                    println(pendingNotificationObject)
//                    //imageObject.saveInBackground()
//                    pendingNotificationObject.saveInBackgroundWithBlock(nil)
//                    pendingNotificationObject.unpinInBackground()
                    
                    //pendingNotificationObject
                    

//                    
//                    let query2 = Notification.query()
//                    query2!.fromLocalDatastore()
//                    
//                    query2!.findObjectsInBackgroundWithBlock({
//                        (results: [AnyObject]?, error: NSError?) -> Void in
//                        let relations = results as? [Notification] ?? []
//                        
//                        //self.pendingNotifications = relations
//                        
//                        for what in relations {
//                            println(what)
//                        }
//                    })
//                    
                    pendingNotificationObject.uploadNotification()
                    //let pendingNotificationObjectId = pendingNotificationObject.objectId
                    
//                    let query = Notification.query()
//                    query!.fromLocalDatastore()
//                    query.getObjectInBackgroundWithId(pendingNotificationObjectId!).continueWithBlock({
//                        (task: BFTask!) -> AnyObject! in
//                        if task.error != nil {
//                            // There was an error.
//                            println("Errrrorororro")
//                            return task
//                        }
//                        
//                        let notificationObj = task.result as! PFObject
//                        notificationObj.saveInBackgroundWithBlock(nil)
//                        notificationObj.unpinInBackgroundWithBlock(nil)
//                        //task.result
//                        // task.result will be your game score
//                        return task
//                    })
//                    
                    
                    /*
                    pendingNotificationObject.fetchFromLocalDatastoreInBackground().continueWithBlock({
                        (task: BFTask!) -> AnyObject! in
                        if task.error != nil {
                            // There was an error.
                            println("Errrrror")
                            return task
                        }
                        
                        task.result.saveInBackgroundWithBlock(nil)
                        task.result.unpinInBackgroundWithBlock(nil)
                        // task.result will be your game score
                        return task
                    }) */
                    
                    

                    
                    
                    println("Reachable via WiFi")
                    TSMessage.dismissActiveNotification()
                    TSMessage.showNotificationInViewController(self, title: "Image successfully sent!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)
                    
                    
                } else { /* Cellular network */
                    println("Reachable via Cellular Network")
                    SweetAlert().showAlert("No Wi-Fi connection.", subTitle: "Would you like to send the photo using cellular data?", style: AlertStyle.Warning, buttonTitle:"No thanks.", buttonColor: UIColor.colorFromRGB(0x66B2FF) , otherButtonTitle:  "Yes, send it.", otherButtonColor: UIColor.colorFromRGB(0x66B2FF/*0x90AEFF*/)) { (isOtherButton) -> Void in
                        if isOtherButton == true {
                            
                            println("Cancel Button  Pressed")
                        }
                        else {
                            SweetAlert().showAlert("Image sent!", subTitle: "", style: AlertStyle.Success)
                        }
                        
                    }
                }
            } else { /* No connection at all */
                SweetAlert().showAlert("No Connection.", subTitle: "Sorry, can't send a photo right now.", style: AlertStyle.None)
                println("NOOOO")
            }
            
        }
            
    }
}

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 30
        } else if section == 1 {
            return 0
        } else {
            return 30
        }
    }
}

extension NotificationsViewController: MPCManagerDelegate {
    func invitationWasReceived(fromPeer: String) {}
    func refreshConnectionStatus() {}
    func photoWasReceived(image: UIImage, fromPeer: MCPeerID) {
        self.friendPeerID = fromPeer
        self.images.insert(image, atIndex: 0)
        self.tableView.reloadData()
    }
}