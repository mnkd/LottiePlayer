//
//  PlayerViewModel.swift
//  LottiePlayer
//
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Combine
import Lottie

// MARK: - FrameTimeRange

struct FrameTimeRange {
    let from: AnimationFrameTime
    let to: AnimationFrameTime
}

// MARK: - PlayerViewModel

final class PlayerViewModel {
    // MARK: Internal

    @Published var windowTitle: String = "LottiePlayer"

    let onSpaceKeyDown = PassthroughSubject<Void, Never>()
    let onAnimationChanged = PassthroughSubject<Animation, Never>()
    let onAnimationEndFrameChanged = PassthroughSubject<AnimationFrameTime, Never>()
    let onFrameTimeChanged = PassthroughSubject<FrameTimeRange, Never>()

    var fileURL: URL? {
        didSet {
            if let url = fileURL {
                windowTitle = url.lastPathComponent

                if let animation = Animation.filepath(url.path) {
                    self.animation = animation
                    onAnimationChanged.send(animation)
                    onAnimationEndFrameChanged.send(animation.endFrame)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.onFrameTimeChanged.send(FrameTimeRange(from: 0, to: animation.endFrame))
                    }
                } else {
                    fatalError("Could not create an Animation with \(url.path)")
                }
            }
        }
    }

    func performKeyEvent(_ event: NSEvent, currentFrameTime: AnimationFrameTime) {
        guard KeyEvent(event).canHandle() else { return }
        guard let animation = animation else { return }

        var frameTime = currentFrameTime
        let option = event.modifierFlags.contains(.command)
        let command: AnimationFrameTime = event.modifierFlags.contains(.option) ? 10 : 1

        switch event.keyCode {
        case KeyCode.leftArrow.rawValue:
            frameTime -= command
            frameTime = option ? animation.startFrame : frameTime

        case KeyCode.rightArrow.rawValue:
            frameTime += command
            frameTime = option ? animation.endFrame : frameTime

        case KeyCode.space.rawValue:
            onSpaceKeyDown.send(())
            return

        default:
            break
        }

        onFrameTimeChanged.send(FrameTimeRange(from: frameTime, to: frameTime))
    }

    // MARK: Private

    private var animation: Animation?
}
