//
//  WiFiDirectViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/15/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class WiFiDirectViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, ReceivedPhotoTableViewCellDelegate {

  //  @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var notificationView: UIView!

    

    
    @IBOutlet var initialConstraints: [NSLayoutConstraint]!
    @IBOutlet var finalConstraints: [NSLayoutConstraint]!
    
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var friendPeerID : MCPeerID?
    //var mcBrowser : MCBrowserViewController?
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "importPicture")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "showConnectionPrompt")
        
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .Required)
        mcSession.delegate = self
        
        

    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController!.view.addSubview(notificationView)
        println("Inital: \(notificationView)")
        
        
        for constraint in initialConstraints {
            constraint.active = true
        }
        
        self.notificationView.layoutIfNeeded()
        
        println("Final: \(notificationView)")
        
        
        /*
        println(notificationView)
        
        for constraint in initialConstraints {
            constraint.active = false
        }
        
        for constraint in finalConstraints {
            constraint.active = true
        }
        
        UIView.animateWithDuration(1.0) {
            self.view.layoutIfNeeded()
        }
*/
        
    }
 
    
    /*
    override func viewDidDisappear(animated: Bool) {
        self.navigationController!.view.sendSubviewToBack(notificationView)
    } */


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func importPicture() {
        let picker = UIImagePickerController()
       // picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject: AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    
        // Check if there are any peers to send to.
        if mcSession.connectedPeers.count > 0 {
            // Convert the new image to an NSData object.
            let imageData = UIImagePNGRepresentation(newImage)
            
            // Send it to all peers, ensuring it gets delivered.
            var error: NSError?
            mcSession.sendData(imageData, toPeers: mcSession.connectedPeers, withMode: .Reliable, error: &error)
            sendNotification()
            
            // Show an error message if there's a problem.
            if error != nil {
                let ac = UIAlertController(title: "Send error", message: error!.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showConnectionPrompt() {
        
        for constraint in initialConstraints{
            constraint.active = false
        }
        
        for constraint in finalConstraints {
            constraint.active = true
        }
     /*
        UIView.animateWithDuration(1.0) {
            self.view.layoutIfNeeded()
        }
         */
        
        UIView.animateWithDuration(0.5,
            delay: 0.5,
            options: .LayoutSubviews | .CurveLinear,
            animations: {
                // self.bug.transform = CGAffineTransformMakeRotation(0.0)
                self.notificationView.layoutIfNeeded()
            },
            completion: { finished in
                self.hideNotificationBar()
        })
        
        /*
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .Default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .Default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil) */
        
    }
    
    func hideNotificationBar() {
        for constraint in finalConstraints {
            constraint.active = false
        }
        
        for constraint in initialConstraints {
            constraint.active = true
        }
        
        UIView.animateWithDuration(0.5,
            delay: 2.0,
            options: .LayoutSubviews | .CurveLinear,
            animations: {
                self.notificationView.layoutIfNeeded()
            },
            completion: { finished in
                println("Notification Hidden.")
        })
    }
    
    
    func startHosting(action: UIAlertAction!) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction!) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        presentViewController(mcBrowser, animated: true, completion: nil)
    }
    
    func sendNotification() {
        /*
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertBody = "Photo successfully sent :)"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
     //   localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        println("Notification officially sent!!!") */
    


    }

}

extension WiFiDirectViewController: MCSessionDelegate {
    
    /** Called when a user connects or disconnects from our session
    Is someone connecting, are they now connected, or have they just disconnected?
    */
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        switch state {
        case MCSessionState.Connected:
            println("Connected: \(peerID.displayName)")
            
            //if mcBrowser == nil {
                let alertController = UIAlertController(title: "Connected", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alertController.addAction(dismissAction)
                self.presentViewController(alertController, animated: true, completion: nil)
              //  println( "Nil Browser. Shows up anyways")
            //} 
            /*
            if mcBrowser != nil {
                if !mcBrowser!.isViewLoaded() && mcBrowser!.view.window == nil {
                    let alertController = UIAlertController(title: "Connected", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    alertController.addAction(dismissAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    println(" Browser exists. But only alert when it's not showing")
                }
            } */

            
            
            
        case MCSessionState.Connecting:
            println("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            println("Not Connected: \(peerID.displayName)")

            let alertController = UIAlertController(title: "Lost connection", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let image = UIImage(data: data) {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.friendPeerID = peerID
                self.images.insert(image, atIndex: 0)
                self.tableView.reloadData()
             //   println("Notifaction sent")
              //  self.sendNotification()
                //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
           
        }
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    }
    
}

extension WiFiDirectViewController: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension WiFiDirectViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceivedPhoto") as! ReceivedPhotoTableViewCell
        
        cell.receivedPhotoImageView.image = self.images[indexPath.row]
        
        if let friendPeerID = self.friendPeerID {
            cell.nameLabel.text = friendPeerID.displayName
        }

        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.images.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}


extension WiFiDirectViewController: ReceivedPhotoTableViewCellDelegate {
    func didSelectPhoto(cell: ReceivedPhotoTableViewCell) {
        UIImageWriteToSavedPhotosAlbum(self.images[0], nil, nil, nil)
        println("Image Saved")
        
        let alertController = UIAlertController(title: "Image Saved", message: "Cell Deleted", preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        let cellIndexPath = self.tableView.indexPathForCell(cell)
        self.images.removeAtIndex(cellIndexPath!.row)
        self.tableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}


