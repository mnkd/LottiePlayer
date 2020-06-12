//
//  KeyEvent.swift
//  LottiePlayer
//  
//  Created by Mitsuru Nakada on 2020/06/11.
//  Copyright © 2020 Goodpatch. All rights reserved.
//

import AppKit

struct KeyEvent {
    private let event: NSEvent

    init(_ event: NSEvent) {
        self.event = event
    }

    func canHandle() -> Bool {
        switch event.keyCode {
        case KeyCode.leftArrow.rawValue, KeyCode.rightArrow.rawValue, KeyCode.space.rawValue:
            return true
        default:
            return false
        }
    }
}
