//
//  AnimationView.swift
//  LottiePlayer
//
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Combine
import Lottie

class PlayerView: NSView {
    // MARK: Internal

    var currentFrame: AnimationFrameTime? { animationView?.realtimeAnimationFrame }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default
            .publisher(for: NSWindow.didResizeNotification)
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] notif in
                guard let self = self else { return }
                guard let object = notif.object as? NSWindow, let window = self.window else { return }
                guard object == window else { return }

                let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                self.animationView?.frame = rect
            }
            .store(in: &cancellables)
    }

    func setUpAnimation(_ animation: Animation) {
        animationView?.removeFromSuperview()

        let newView = AnimationView(animation: animation)
        newView.loopMode = .playOnce
        newView.contentMode = .scaleAspectFit
        newView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(newView)
        animationView = newView
    }

    func playOrPause() {
        guard
            let animationView = animationView,
            let animation = animationView.animation
        else { return }

        if animationView.isAnimationPlaying {
            animationView.pause()
        } else {
            animationView.play(fromFrame: nil, toFrame: animation.endFrame)
        }
    }

    func play(fromFrame: AnimationFrameTime?, toFrame: AnimationFrameTime) {
        animationView?.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: .playOnce, completion: nil)
    }

    func stop() {
        animationView?.stop()
    }

    // MARK: Private

    private var animationView: AnimationView?
    private var cancellables = Set<AnyCancellable>()
}
