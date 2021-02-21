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
    // MARK: Lifecycle

    deinit {
        if let monitor = self.keyDownMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    // MARK: Internal

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

        viewModel.onAnimationChanged
            .sink { [weak self] in self?.playerView.setUpAnimation($0) }
            .store(in: &cancellables)

        viewModel.onAnimationEndFrameChanged
            .sink { [weak self] in
                self?.slider.maxValue = Double($0)
                self?.endFrameLabel.stringValue = "/\(Int($0))"
            }
            .store(in: &cancellables)

        viewModel.onFrameTimeChanged
            .sink { [weak self] in self?.playerView.play(fromFrame: $0.from, toFrame: $0.to) }
            .store(in: &cancellables)

        viewModel.onSpaceKeyDown
            .sink { [weak self] in self?.playerView.playOrPause() }
            .store(in: &cancellables)

        Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let frameTime = self?.playerView.currentFrame else { return }
                let value = Int(frameTime)
                self?.slider.integerValue = value
                self?.currentFrameLabel.stringValue = "\(value)"
            }
            .store(in: &cancellables)

        startKeyEventMonitoring()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        viewModel.$windowTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.view.window?.title = $0 }
            .store(in: &cancellables)
    }

    // MARK: Private

    @IBOutlet private var playerView: PlayerView!
    @IBOutlet private var draggingDestinationView: DraggingDestinationView!
    @IBOutlet private var slider: NSSlider!
    @IBOutlet private var currentFrameLabel: NSTextField!
    @IBOutlet private var endFrameLabel: NSTextField!

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = PlayerViewModel()
    private var keyDownMonitor: Any?

    @IBAction private func sliderAction(_ sender: NSSlider) {
        let frameTime = AnimationFrameTime(sender.integerValue)
        playerView.play(fromFrame: frameTime, toFrame: frameTime)
    }

    private func startKeyEventMonitoring() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event -> NSEvent? in
            guard let self = self else { return nil }
            guard let window = self.view.window, window.isKeyWindow else { return event }
            guard KeyEvent(event).canHandle() else { return event }

            self.viewModel.performKeyEvent(event, currentFrameTime: AnimationFrameTime(self.slider.integerValue))
            return nil
        }
    }
}
