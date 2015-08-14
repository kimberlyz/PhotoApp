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
import RealmSwift

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var notifications = [Notification]()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var zaps = [Zap]()

    var delayedNotifications = [Notification]()

    
    var notificationsSectionTitles : [String] = ["Received", "", "Pending"]
    
    var pendingNotifications: Results<PendingNotification>!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotifications()
        
        self.zaps = appDelegate.mpcManager.zaps
        
        //self.navigationController!.navigationBar.barTintColor = UIColor.colorFromRGB(0x263A9F)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = Realm()
        
        self.tableView.addSubview(self.refreshControl)
        
        reachability.startNotifier()
        
        pendingNotifications = realm.objects(PendingNotification)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        getNotifications()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func getNotifications() {
        ParseHelper.getNotifications(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ParseErrorHandlingController.handleParseError(error)
            }
            
            let relations = results as? [Notification] ?? []
            
            self.notifications = relations
            self.tableView.reloadData()
        }
    }
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {

    }
}

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return notificationsSectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.zaps.count
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ZapCell") as! ZapTableViewCell
            
            cell.usernameLabel.text = self.zaps[indexPath.row].peerID?.displayName
            cell.photo = self.zaps[indexPath.row].image

            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
            
            let notificationObject = self.notifications[indexPath.row]
            cell.fromUser = notificationObject.objectForKey(ParseHelper.ParseNotificationFromUser) as? PFUser
            
            if notificationObject.imagePic != nil {
                cell.notificationsImageView.image = notificationObject.imagePic
            } else {
                var image = UIImage(named: "ImagePlaceholder.png")
                cell.notificationsImageView.image = image
            }

            
            return cell
        } else {
            // Some wonky logic....
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
            
            let pendingNotificationObject = self.pendingNotifications[indexPath.row]
            
            var pendingImage = UIImage(named: "PendingImage.png")
            
            cell.usernameLabel.text = pendingNotificationObject.toUserUsername
            cell.notificationsImageView.image = pendingImage
            
            return cell
        }
        
     }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! ZapTableViewCell
        

            UIImageWriteToSavedPhotosAlbum(selectedCell.photo, nil, nil, nil)
            TSMessage.showNotificationInViewController(self, title: "Image saved!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)
                
            let cellIndexPath = self.tableView.indexPathForCell(selectedCell)
                
            self.zaps.removeAtIndex(cellIndexPath!.row)
            appDelegate.mpcManager.zaps.removeAtIndex(cellIndexPath!.row)
                
            self.tableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)

            
        } else if indexPath.section == 1 { /* Is an image sent from Wi-Fi */
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationsTableViewCell
            
            let notificationObject = self.notifications[indexPath.row]
            
            // Image hasn't been downloaded yet, so download it
            if notificationObject.imagePic == nil {
                
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
                                    
                                    let image = UIImage(data: imageData)
                                    notificationObject.imagePic = image
                                    
                                    selectedCell.notificationsImageView.image = image
                                    
                                    selectedCell.activityIndicator.stopAnimating()
                                    
                                    self.tableView.reloadData()
                                }
                                
                            }
                        }
                    } else {
                        ParseErrorHandlingController.handleParseError(error!)
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
                        ParseErrorHandlingController.handleParseError(error!)
                    }
                }

                self.tableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        } else { /* Pending cell */
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
            
            let pendingNotificationObject = self.pendingNotifications[indexPath.row]
            
            // Initial reachability check
            if reachability.isReachable() {
                if reachability.isReachableViaWiFi() {
                    
                    let realm = Realm()
                    let query = PFUser.query()
                    query!.whereKey("objectId", equalTo: pendingNotificationObject.toUserObjectId)
                    
                    query!.findObjectsInBackgroundWithBlock {
                        (results: [AnyObject]?, error: NSError?) -> Void in
                        if error == nil {
                            let results = results as? [PFUser] ?? []
                        
                            for user in results {
                                let notification = Notification()
                                notification.toUser = user
                                notification.fromUser = PFUser.currentUser()!
                                notification.imageFile = PFFile(data: pendingNotificationObject.imageData)
                            
                                notification.uploadNotification { (success: Bool, error: NSError?) -> Void in
                                    if error != nil {
                                        SweetAlert().showAlert("Upload failed.", subTitle: "Leaving photo in the pending section.", style: AlertStyle.Warning)
                                    } else {
                                        realm.write() {
                                            realm.delete(pendingNotificationObject)
                                        }
                                        
                                        self.pendingNotifications = realm.objects(PendingNotification)
                                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                                    }
                                }

                            }
                        } else {
                            ParseErrorHandlingController.handleParseError(error!)
                        }
                    }
                    
                    println("Reachable via WiFi")
                    TSMessage.dismissActiveNotification()
                    TSMessage.showNotificationInViewController(self, title: "Image successfully sent!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)

                    
                } else { /* Cellular network */
                    println("Reachable via Cellular Network")
                    SweetAlert().showAlert("No Wi-Fi connection.", subTitle: "Would you like to send the photo using cellular data?", style: AlertStyle.Warning, buttonTitle:"No thanks.", buttonColor: UIColor.colorFromRGB(0x66B2FF) , otherButtonTitle:  "Yes, send it.", otherButtonColor: UIColor.colorFromRGB(0x66B2FF)) { (isOtherButton) -> Void in
                        if isOtherButton == true {
                            
                            println("Cancel Button  Pressed")
                        }
                        else {
                            
                            let realm = Realm()
                            let query = PFUser.query()
                            query!.whereKey("objectId", equalTo: pendingNotificationObject.toUserObjectId)
                            
                            query!.findObjectsInBackgroundWithBlock {
                                (results: [AnyObject]?, error: NSError?) -> Void in
                                if error == nil {
                                    let results = results as? [PFUser] ?? []
                                    
                                    for user in results {
                                        let notification = Notification()
                                        notification.toUser = user
                                        notification.fromUser = PFUser.currentUser()!
                                        notification.imageFile = PFFile(data: pendingNotificationObject.imageData)
                                        
                                        notification.uploadNotification { (success: Bool, error: NSError?) -> Void in
                                            if error != nil {
                                                SweetAlert().showAlert("Upload failed.", subTitle: "Leaving photo in the pending section.", style: AlertStyle.Warning)
                                            } else {
                                                realm.write() {
                                                    realm.delete(pendingNotificationObject)
                                                }
                                                
                                                self.pendingNotifications = realm.objects(PendingNotification)
                                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                                            }
                                        }
                                    }
                                } else {
                                    ParseErrorHandlingController.handleParseError(error!)
                                }
                            }

                            
                            /// DO SOMETHING HERE!!!!! SEND IT
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
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            if indexPath.section == 0 { /* Zap cells */
                self.zaps.removeAtIndex(indexPath.row)
                appDelegate.mpcManager.zaps.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                
            } else if indexPath.section == 1 { /* Wi-Fi cells */
                
                let notificationObject = self.notifications[indexPath.row]
                
                let query = PFQuery(className:ParseHelper.ParseNotificationClass)
                let notificationObjectId = notificationObject.objectId
                
                query.getObjectInBackgroundWithId(notificationObjectId!) {
                    (notificationObj: PFObject?, error: NSError?) -> Void in
                    if error == nil && notificationObj != nil {
                        println(notificationObj)
                        notificationObj!.deleteInBackgroundWithBlock(nil)
                        self.notifications.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    } else {
                        ParseErrorHandlingController.handleParseError(error!)
                    }
                }


            } else {
                
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
            if self.pendingNotifications.count == 0 {
                return 0
            } else {
                return 30
            }
        }
    }
}