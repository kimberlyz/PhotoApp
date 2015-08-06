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

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [Notification]()
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
        
        //getNotifications()
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didStartReceivingResourceWithNotification:", name: "MPCDidStartReceivingResourceNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateReceivingProgressWithNotification:", name: "MPCReceivingProgressNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishReceivingResourceNotification", name: "didFinishReceivingResourceNotification", object: nil)
        
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
//        let newMovie = Movie(title: "Serenity", genre: "Sci-fi")
//        movies.append(newMovie)
//        
//        movies.sort() { $0.title < $1.title }
        
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
        let query = PFQuery(className:"Notification")
        query.fromLocalDatastore()
        query.getObjectInBackgroundWithId("xWMyZ4YEGZ").continueWithBlock({
            (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                // There was an error.
                return task
            }
            
            // task.result will be your game score
            return task
        })
    }
    

    /*
    func getNotifications() {
        ParseHelper.getNotifications(PFUser.currentUser()!) {
            (results: [AnyObject]?, error: NSError?) -> Void in
            let relations = results as? [PFObject] ?? []
            
            
            
            var userArray = [PFUser]()
            userArray = relations.map {
                $0.objectForKey(ParseHelper.ParsePhotoFromUser) as! PFUser
            }
            
            var imageArray = [PFObject]()
            imageArray = relations.map {
                $0.objectForKey(ParseHelper.ParsePhotoImage) as! PFObject
            }
            
            var imageFileArray = [PFFile]()
            imageFileArray = imageArray.map {
                $0.objectForKey(ParseHelper.ParseImageImageFile) as! PFFile
            }
        
            for var i = 0; i < userArray.count; i++ {
                
                
                let imageFile = imageFileArray[i]
                
                imageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        let image = UIImage(data: imageData!)
                        //var airports = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
                        let dict: [PFUser : UIImage] = [userArray[i]: image!]
                        self.notifications.append(dict)
                        
                        //self.notifications[i][currentUser] = imageFileArray[i]
                    }
                    
                }
                
               // self.notifications[userArray[i]] = imageFileArray[i]
            }
            /*
            for user in userArray {
                self.notifications[user] =
            }
            //self.notifications[
            for imageFile in imageFileArray {
                println("Hi")
                
                imageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        let image = UIImage(data: imageData!)
                    }
                    
                }
                
            } */
            
            self.tableView.reloadData()
        }
    } */
    
    
    func didStartReceivingResourceWithNotification(notification: NSNotification) {
        senderInfo.append(notification.userInfo!)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func updateReceivingProgressWithNotification(notification: NSNotification) {
        var userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        var progress = userInfo["progress"] as! NSProgress
        var dict: [String: AnyObject] = senderInfo[senderInfo.count-1] as! [String : AnyObject]
        var updatedDict: [String: AnyObject] = ["resourceName" : dict["resourceName"]!, "peerID" : dict["peerID"]!, "progress" : progress] as [String: AnyObject]
        
        senderInfo.removeLast()
        senderInfo.append(updatedDict)
     
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
    }
    
    func didFinishReceivingResourceWithNotification(notification: NSNotification) {
        var dict = notification.userInfo as! Dictionary<String, AnyObject>
        var localURL = dict["localURL"] as! NSURL
        
        var localURLArray : [NSURL] = []
        localURLArray.append(localURL)
        
        let fetchResult = PHAsset.fetchAssetsWithALAssetURLs(localURLArray, options: nil)
        
        var asset = fetchResult[0] as? PHAsset
        
        
//        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
//        let targetSize = CGSizeMake(screenSize.width, screenSize.height)
        
        let targetSize = CGSize(width: 80.0, height: 80.0)
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
            
            if let image = result {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.images.insert(image, atIndex: 0)
                    //self.imageView = UIImageView(image: result)
                    self.tableView.reloadData()
                }
            }
            
        })
        
//        if let image = UIImage(data: data) {
//            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//                self.friendPeerID = peerID
//                self.images.insert(image, atIndex: 0)
//                self.tableView.reloadData()
//                //   println("Notifaction sent")
//                //  self.sendNotification()
//                //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            }
//            
//        }
    }
    
    //var imageView: UIImageView!
    

    
//    
//    var options = PHImageRequestOptions()
//    //        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
//    options.resizeMode = PHImageRequestOptionsResizeMode.Exact
    
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
        
        return self.notifications.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return notificationsSectionTitles[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
        
        let notificationObject = self.notifications[indexPath.row]
        
        cell.fromUser = notificationObject.objectForKey(ParseHelper.ParseNotificationFromUser) as? PFUser
        //cell.notificationsImageView.image = notificationObject.objectFor
        
//        let imageObject = PFObject(className: "Image")
//        imageObject.setObject(imageFile, forKey: "imageFile")
        /*
        let imageObject = notificationObject.objectForKey(ParseHelper.ParseNotificationImage) as? PFObject
        
        if let imageObject = imageObject {
            let imageFile = imageObject.objectForKey(ParseHelper.ParseImageImageFile) as! PFFile
            
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    if let imageData = imageData {
                        //let image = UIImage(data: imageData, scale:1.0)!
                        
                        let image = UIImage(data: imageData)
                        cell.notificationsImageView.image = image
                        
                        self.tableView.reloadData()
                        
                        // 3
                        //self.image.value = image
                    }
                    
                }
            }
        } */

        

        //cell.imageView!.image = notificationObject.objectForKey(ParseHelper.ParseNotificationImage) as? UIImage
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationsTableViewCell
        
        
        let notificationObject = self.notifications[indexPath.row]
        
        if notificationObject.imagePic == nil {
        
            let imageObject = notificationObject.objectForKey(ParseHelper.ParseNotificationImage) as? PFObject
        
            if let imageObject = imageObject {
                let imageFile = imageObject.objectForKey(ParseHelper.ParseImageImageFile) as! PFFile
            
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
                        
                            // 3
                            //self.image.value = image
                        }
                    
                    }
                }
            }
        } else {
            TSMessage.showNotificationInViewController(self, title: "Image saved!", subtitle: "", type: .Success, duration: 1.0, canBeDismissedByUser: true)
            
            //TSMessage.showNotificationInViewController(self, title: "Imaged saved!", subtitle: "", type: )


//            
//            
//            // Add a button inside the message
//            [TSMessage showNotificationInViewController:self
//            title:@"Update available"
//            subtitle:@"Please update the app"
//            image:nil
//            type:TSMessageNotificationTypeMessage
//            duration:TSMessageNotificationDurationAutomatic
//            callback:nil
//            buttonTitle:@"Update"
//            buttonCallback:^{
//            NSLog(@"User tapped the button");
//            }
//            atPosition:TSMessageNotificationPositionTop
//            canBeDismissedByUser:YES];
            
            UIImageWriteToSavedPhotosAlbum(notificationObject.imagePic, nil, nil, nil)
            println("Image Saved")
        }
        
    }
    
    /*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationsCell") as! NotificationsTableViewCell
        
//        cell.usernameLabel.text = "Merp"
//
//        return cell
        
        // as?
        if senderInfo[indexPath.row] is String {
            cell.usernameLabel.text = senderInfo[indexPath.row] as? String
    
        } else {
//            // Get the dictionary containing the data and the source peer from the notification.
//            let receivedDataDictionary = notification.object as Dictionary<String, AnyObject>
//            
//            // "Extract" the data and the source peer from the received dictionary.
//            let data = receivedDataDictionary["data"] as? NSData
//            let fromPeer = receivedDataDictionary["fromPeer"] as MCPeerID

            var dict = senderInfo[indexPath.row] as! Dictionary<String, AnyObject>
            
            //var dict: [String: AnyObject] = senderInfo[indexPath.row] as! [String : AnyObject]
            var peerDisplayName = dict["peerID"]!.displayName
            var progress = dict["progress"]!.progress
            
            cell.usernameLabel.text = peerDisplayName
            cell.progressView.setProgress(progress, animated: true)
            
        }
        
        return cell
        
////        if ([[_arrFiles objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
////            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
////            
////            if (cell == nil) {
////                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
////                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
////            }
////            
////            cell.textLabel.text = [_arrFiles objectAtIndex:indexPath.row];
////            
////            [[cell textLabel] setFont:[UIFont systemFontOfSize:14.0]];
////        }
//        else{
//            cell = [tableView dequeueReusableCellWithIdentifier:@"newFileCellIdentifier"];
//            
//            NSDictionary *dict = [_arrFiles objectAtIndex:indexPath.row];
//            NSString *receivedFilename = [dict objectForKey:@"resourceName"];
//            NSString *peerDisplayName = [[dict objectForKey:@"peerID"] displayName];
//            NSProgress *progress = [dict objectForKey:@"progress"];
//            
//            [(UILabel *)[cell viewWithTag:100] setText:receivedFilename];
//            [(UILabel *)[cell viewWithTag:200] setText:[NSString stringWithFormat:@"from %@", peerDisplayName]];
//            [(UIProgressView *)[cell viewWithTag:300] setProgress:progress.fractionCompleted];
//        }
//        
//        return cell;
        
    } */
    
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
        
        if section == 0 {
            return 30
        } else if section == 1 {
            return 0
        } else {
            return 30
        }
        
        //return 30
        
//        if section == 0 && (self.requestingUsers == nil || self.requestingUsers?.count == 0) {
//            return 0
//        } else if section == 2 && self.friendUsers.count == 0 {
//            return 0}
//        else {
//            return 30
//        }
    }
    
}