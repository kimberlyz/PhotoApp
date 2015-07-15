//
//  PhotoTakingHelper.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 7/13/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper: NSObject {
    
    /** View controller on which AlertViewController and UIImagePickerController are presented */
    weak var viewController: UIViewController!
    weak var sourceViewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, sourceViewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.sourceViewController = sourceViewController
        self.callback = callback
        
        super.init()
        
        if (sourceViewController is CameraViewController) {
            showPhotoSourceSelection()
        } else if (sourceViewController is AlbumViewController) {
            self.showImagePickerController(.PhotoLibrary)
        } else {
            println("Source View Controller is not Camera or Album")
        }

    }
    
    func showPhotoSourceSelection() {
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            self.showImagePickerController(.Camera)
        } else {
            println("Rear Camera cannot be found.")
        }
        
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }

}

// Should functions be implemented? Or be empty? Both are optional
extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Called when image is selected
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
        callback(image)
    }
    
    // Called when cancel button is tapped?
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

