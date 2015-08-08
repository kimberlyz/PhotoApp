//
//  ZapTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/7/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit

class ZapTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var zapImageView: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var photo: UIImage? {
        didSet {
            if let photo = photo {
                zapImageView.image = photo
                
                if activityIndicator.isAnimating() {
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
}
