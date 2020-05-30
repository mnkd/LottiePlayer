//
//  PlayerViewController.swift
//  
//  
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Combine
import Lottie

class PlayerViewController: NSViewController {
    @IBOutlet private weak var playerView: PlayerView!
    @IBOutlet private weak var draggingDestinationView: DraggingDestinationView!
    @IBOutlet private weak var slider: NSSlider!

    private class Subscriptions {
        var draggedFileURL: AnyCancellable?
        var keyDownEvent: AnyCancellable?
        var windowTitle: AnyCancellable?

        var toggleAnimation: AnyCancellable?
        var changeAnimation: AnyCancellable?
        var changeProgress: AnyCancellable?

        var timer: AnyCancellable?
        var progress: AnyCancellable?
    }

    private let subscriptions = Subscriptions()
    private let viewModel = PlayerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        subscriptions.draggedFileURL = draggingDestinationView.draggedFileURL
            .sink { url in
                self.viewModel.fileURL = url
            }

        subscriptions.changeAnimation = viewModel.changeAnimation
            .sink { url in
                self.playerView.setUpAnimation(filePath: url.path)
                self.playerView.play()
            }

        subscriptions.changeProgress = viewModel.changeProgress
            .sink { range in
                self.playerView.play(fromProgress: range.from, toProgress: range.to)
            }

        subscriptions.toggleAnimation = viewModel.toggleAnimation
            .sink {
                self.playerView.playOrPause()
            }

        subscriptions.progress = viewModel.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: \.floatValue, on: slider)

        setUpTimer()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let window = view.window as? PlayerWindow {

            subscriptions.keyDownEvent = window.keyDownEvent
                .map { ($0, self.slider.floatValue) }
                .sink { (event, progress) in
                    self.viewModel.keyDown(event, currentProgress: progress)
                }

            subscriptions.windowTitle = viewModel.$windowTitle
                .receive(on: DispatchQueue.main)
                .assign(to: \.title, on: window)
        }
    }

    @IBAction func sliderAction(_ sender: NSSlider) {
        let progress = CGFloat(sender.floatValue)
        playerView.play(fromProgress: progress, toProgress: progress)
    }

    // MARK: - Private

    private func setUpTimer() {
        guard subscriptions.timer == nil else { return }
        let publisher = Timer.publish(every: 0.01, on: RunLoop.main, in: .common)
            .autoconnect()

        subscriptions.timer = publisher.sink { [weak self] _ in
            guard let progress = self?.playerView.currentProgress else { return }
            self?.slider.floatValue = Float(progress)
        }
    }
}
