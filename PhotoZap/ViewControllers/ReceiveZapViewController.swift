//
//  ReceiveZapViewController.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/3/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit

class ReceiveZapViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension ReceiveZapViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Finding Nearby Devices..."
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceiveZapCell") as! ReceiveZapTableViewCell
        
        cell.usernameLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        cell.connectionStatusLabel.text = "Not connected"
        
        return cell
    }

}