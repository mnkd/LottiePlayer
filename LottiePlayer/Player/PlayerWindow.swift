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
    let keyDownEvent = PassthroughSubject<NSEvent, Never>()

    override func awakeFromNib() {
        super.awakeFromNib()
        title = "LottiePlayer"
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        keyDownEvent.send(event)
    }
}
