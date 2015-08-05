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

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var images = [UIImage]()
    
    // UHHH
    var senderInfo = [AnyObject]()  // var dict: [String: AnyObject]
    
    var notificationsSectionTitles : [String] = ["Received", "Pending"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didStartReceivingResourceWithNotification:", name: "MPCDidStartReceivingResourceNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateReceivingProgressWithNotification:", name: "MPCReceivingProgressNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishReceivingResourceNotification", name: "didFinishReceivingResourceNotification", object: nil)
        
    }
    
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
        var updatedDict: AnyObject = ["resourceName" : dict["resourceName"], "peerID" : dict["peerID"], "progress" : progress] as! AnyObject
        
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
                    self.imageView = UIImageView(image: result)
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
    
    var imageView: UIImageView!
    

    
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
        
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return notificationsSectionTitles[section]
    }
    
    
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