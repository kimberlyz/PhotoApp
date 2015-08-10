//
//  Zap.swift
//  PhotoZap
//
//  Created by Kimberly Zai on 8/10/15.
//  Copyright (c) 2015 Kimberly Zai. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Zap: NSObject {
    var peerID : MCPeerID?
    var image: UIImage?
    
    init(peerID: MCPeerID, image: UIImage) {
        self.peerID = peerID
        self.image = image
    }
}