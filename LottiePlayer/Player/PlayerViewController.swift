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

    private var subscriptions = Set<AnyCancellable>()
    private let viewModel = PlayerViewModel()

    override var representedObject: Any? {
        didSet {
            if let content = representedObject as? Content {
                self.draggingDestinationView.isLabelHidden = true
                self.viewModel.fileURL = content.url
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        draggingDestinationView.droppedFileURL
            .sink { self.viewModel.fileURL = $0 }
            .store(in: &subscriptions)

        viewModel.changeAnimation
            .sink { self.playerView.setUpAnimation(filePath: $0.path) }
            .store(in: &subscriptions)

        viewModel.changeProgress
            .sink { self.playerView.play(fromProgress: $0.from, toProgress: $0.to) }
            .store(in: &subscriptions)

        viewModel.toggleAnimation
            .sink { self.playerView.playOrPause() }
            .store(in: &subscriptions)

        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: \.floatValue, on: slider)
            .store(in: &subscriptions)

        Timer.publish(every: 0.01, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink { _ in
                guard let progress = self.playerView.currentProgress else { return }
                self.slider.floatValue = Float(progress)
            }
            .store(in: &subscriptions)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let window = view.window as? PlayerWindow {
            window.keyDownEvent
                .map { ($0, self.slider.floatValue) }
                .sink { (event, progress) in
                    self.viewModel.keyDown(event, currentProgress: progress)
                }
                .store(in: &subscriptions)

            viewModel.$windowTitle
                .receive(on: DispatchQueue.main)
                .assign(to: \.title, on: window)
                .store(in: &subscriptions)
        }
    }

    @IBAction func sliderAction(_ sender: NSSlider) {
        let progress = CGFloat(sender.floatValue)
        playerView.play(fromProgress: progress, toProgress: progress)
    }
}
