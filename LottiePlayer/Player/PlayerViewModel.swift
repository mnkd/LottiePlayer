//
//  PlayerViewModel.swift
//  LottiePlayer
//  
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Combine

struct ProgressRange {
    let from: CGFloat
    let to: CGFloat
}

final class PlayerViewModel {
    @Published var windowTitle: String = "LottiePlayer"
    @Published var progress: Float = 0

    let toggleAnimation = PassthroughSubject<Void, Never>()
    let changeAnimation = PassthroughSubject<URL, Never>()
    let changeProgress = PassthroughSubject<ProgressRange, Never>()

    var fileURL: URL? {
        didSet {
            if let url = fileURL {
                windowTitle = url.lastPathComponent
                changeAnimation.send(url)
            }
        }
    }

    func keyDown(_ event: NSEvent, currentProgress: Float) {
        var progress = CGFloat(currentProgress)
        let option = event.modifierFlags.contains(.command)
        let command: CGFloat = event.modifierFlags.contains(.option) ? 20 : 1

        switch event.keyCode {
        case KeyCode.leftArrow.rawValue:
            progress -= (0.001 * command)
            progress = option ? 0 : progress

        case KeyCode.rightArrow.rawValue:
            progress += (0.001 * command)
            progress = option ? 1 : progress

        case KeyCode.space.rawValue:
            toggleAnimation.send(Void())
            return

        default:
            break
        }

        self.progress = Float(progress)
        changeProgress.send(ProgressRange(from: progress, to: progress))
    }
}
