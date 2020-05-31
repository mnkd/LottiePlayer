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

    private var cancellables = Set<AnyCancellable>()
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

        draggingDestinationView.onFileURLDropped
            .sink { [weak self] in self?.viewModel.fileURL = $0 }
            .store(in: &cancellables)

        viewModel.onAnimationURLChanged
            .sink { [weak self] in self?.playerView.setUpAnimation(filePath: $0.path) }
            .store(in: &cancellables)

        viewModel.onProgressChanged
            .sink { [weak self] in self?.playerView.play(fromProgress: $0.from, toProgress: $0.to) }
            .store(in: &cancellables)

        viewModel.onSpaceKeyDown
            .sink { [weak self] in self?.playerView.playOrPause() }
            .store(in: &cancellables)

        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: \.floatValue, on: slider)
            .store(in: &cancellables)

        Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let progress = self?.playerView.currentProgress else { return }
                self?.slider.floatValue = Float(progress)
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let window = view.window as? PlayerWindow {
            window.keyDownEvent
                .map { [weak self] in
                    guard let self = self else { return ($0, 0) }
                    return ($0, self.slider.floatValue)
                }
                .sink { [weak self] (event, progress) in
                    self?.viewModel.keyDown(event, currentProgress: progress)
                }
                .store(in: &cancellables)

            viewModel.$windowTitle
                .receive(on: DispatchQueue.main)
                .assign(to: \.title, on: window)
                .store(in: &cancellables)
        }
    }

    @IBAction func sliderAction(_ sender: NSSlider) {
        let progress = CGFloat(sender.floatValue)
        playerView.play(fromProgress: progress, toProgress: progress)
    }
}
