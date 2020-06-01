//
//  PlayerWindow.swift
//  LottiePlayer
//  
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Combine

class PlayerWindow: NSWindow {
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "LottiePlayer"
    }
}
