//
//  KeyEvent.swift
//  LottiePlayer
//
//  Created by Mitsuru Nakada on 2020/06/11.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import AppKit

struct KeyEvent {
    // MARK: Lifecycle

    init(_ event: NSEvent) {
        self.event = event
    }

    // MARK: Internal

    func canHandle() -> Bool {
        switch event.keyCode {
        case KeyCode.leftArrow.rawValue, KeyCode.rightArrow.rawValue, KeyCode.space.rawValue:
            return true
        default:
            return false
        }
    }

    // MARK: Private

    private let event: NSEvent
}
