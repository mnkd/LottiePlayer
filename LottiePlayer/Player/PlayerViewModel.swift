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

    let onSpaceKeyDown = PassthroughSubject<Void, Never>()
    let onAnimationURLChanged = PassthroughSubject<URL, Never>()
    let onProgressChanged = PassthroughSubject<ProgressRange, Never>()

    var fileURL: URL? {
        didSet {
            if let url = fileURL {
                windowTitle = url.lastPathComponent
                onAnimationURLChanged.send(url)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.onProgressChanged.send(ProgressRange(from: 0, to: 1))
                }
            }
        }
    }

    func canHandleKeyEvent(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case KeyCode.leftArrow.rawValue, KeyCode.rightArrow.rawValue, KeyCode.space.rawValue:
            return true
        default:
            return false
        }
    }

    func performKeyEvent(_ event: NSEvent, currentProgress: Float) {
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
            onSpaceKeyDown.send(Void())
            return

        default:
            break
        }

        self.progress = Float(progress)
        onProgressChanged.send(ProgressRange(from: progress, to: progress))
    }
}
