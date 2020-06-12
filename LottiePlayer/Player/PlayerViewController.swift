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
    @IBOutlet private weak var frameLabel: NSTextField!

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = PlayerViewModel()
    private var keyDownMonitor: Any?

    deinit {
        if let monitor = self.keyDownMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

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
            .map { Double($0) }
            .assign(to: \.maxValue, on: slider)
            .store(in: &cancellables)

        viewModel.onFrameTimeChanged
            .sink { [weak self] in self?.playerView.play(fromFrame: $0.from, toFrame: $0.to) }
            .store(in: &cancellables)

        viewModel.onSpaceKeyDown
            .sink { [weak self] in self?.playerView.playOrPause() }
            .store(in: &cancellables)

        viewModel.$currentFrameTime
            .receive(on: DispatchQueue.main)
            .map { Int($0) }
            .assign(to: \.integerValue, on: slider)
            .store(in: &cancellables)

        slider
            .publisher(for: \.integerValue)
            .map { String($0) }
            .assign(to: \.stringValue , on: frameLabel)
            .store(in: &cancellables)

        Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let frameTime = self?.playerView.currentFrame else { return }
                self?.slider.integerValue = Int(frameTime)
            }
            .store(in: &cancellables)

        startKeyEventMonitoring()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let window = view.window as? PlayerWindow {
            viewModel.$windowTitle
                .receive(on: DispatchQueue.main)
                .assign(to: \.title, on: window)
                .store(in: &cancellables)
        }
    }

    @IBAction func sliderAction(_ sender: NSSlider) {
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
