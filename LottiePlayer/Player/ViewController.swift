//
//  ViewController.swift
//  
//  
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Lottie

class ViewController: NSViewController {
    @IBOutlet private weak var playerView: PlayerView!
    @IBOutlet private weak var draggingDestinationView: DraggingDestinationView!
    @IBOutlet private weak var slider: NSSlider!
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        draggingDestinationView.delegate = self
        startTimer()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window as? PlayerWindow {
            window.handler = { event in
                self.keyDownHandler(event)
            }
        }
    }

    @IBAction func sliderAction(_ sender: NSSlider) {
        let progress = CGFloat(sender.floatValue)
        playerView.play(fromProgress: progress, toProgress: progress)
    }

    // MARK: - Private

    @objc private func updateProgress() {
        guard let progress = playerView.currentProgress else { return }
        slider.floatValue = Float(progress)
    }

    private func startTimer() {
        guard self.timer == nil else { return }
        let timer = Timer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func keyDownHandler(_ event: NSEvent) {
        var progress = CGFloat(slider.floatValue)
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
            playerView.playOrPause()
            return

        default:
            break
        }

        slider.floatValue = Float(progress)
        playerView.play(fromProgress: progress, toProgress: progress)
    }
}

extension ViewController: DraggingDestinationViewDelegate {
    func draggingDestinationView(draggedFileURL: URL) {
        view.window?.title = draggedFileURL.lastPathComponent
        playerView.setUpAnimation(filePath: draggedFileURL.path)
        playerView.play()
    }
}
