//
//  AnimationView.swift
//  LottiePlayer
//  
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Lottie

class PlayerView: NSView {

    var currentProgress: AnimationProgressTime? { animationView?.realtimeAnimationProgress }
    private var animationView: AnimationView?

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notif in
                guard let self = self else { return }
                self.animationView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            }
    }

    func setUpAnimation(filePath: String) {
        animationView?.removeFromSuperview()

        let newView = Lottie.AnimationView(filePath: filePath)
        newView.loopMode = .playOnce
        newView.contentMode = .scaleAspectFit
        newView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(newView)
        animationView = newView
    }

    func play() {
        animationView?.play()
    }

    func playOrPause() {
        let isAnimationPlaying = animationView?.isAnimationPlaying ?? false
        if  isAnimationPlaying {
            animationView?.pause()
        } else {
            animationView?.play(fromProgress: nil, toProgress: 1)
        }
    }

    func play(fromProgress: AnimationProgressTime?, toProgress: AnimationProgressTime) {
        animationView?.play(
            fromProgress: fromProgress,
            toProgress: toProgress,
            loopMode: .playOnce,
            completion: nil)
    }

    func stop() {
        animationView?.stop()
    }
}
