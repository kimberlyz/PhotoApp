//
//  ReceivedPhotoTableViewCell.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/16/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit

protocol ReceivedPhotoTableViewCellDelegate: class {
    func didSelectPhoto(cell: ReceivedPhotoTableViewCell)
}

class ReceivedPhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var receivedPhotoImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: ReceivedPhotoTableViewCellDelegate?
    
    @IBAction func imageTapped(sender: AnyObject) {
        delegate?.didSelectPhoto(self)
        println("Image tapped and delegate will perform download.")
    }

    
    /*
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    */

}
