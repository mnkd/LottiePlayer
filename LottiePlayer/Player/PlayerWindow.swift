//
//  PlayerWindow.swift
//  LottiePlayer
//  
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa

class PlayerWindow: NSWindow {
    var handler: ((NSEvent) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        title = "LottiePlayer"
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        handler?(event)
    }
}
