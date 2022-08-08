//
//  DraggingDestinationDelegate.swift
//  LottiePlayer
//
//  Created by Mitsuru Nakada on 2020/05/30.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa
import Combine
import os.log

final class DraggingDestinationView: NSView {
    // MARK: Lifecycle

    deinit {
        unregisterDraggedTypes()
    }

    // MARK: Internal

    let onFileURLDropped = PassthroughSubject<URL, Never>()

    var isLabelHidden = false {
        didSet {
            dropHereView.isHidden = isLabelHidden
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        registerForDraggedTypes([.fileURL])
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let color: NSColor = isDragging ? .systemBlue : .clear
        let width: CGFloat = isDragging ? 5 : 0
        let path = NSBezierPath(rect: bounds)
        path.lineWidth = width

        color.set()
        path.stroke()
    }

    // MARK: - NSDraggingDestination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard shouldAllowDrop(sender) else { return [] }

        isDragging = true
        return [.generic]
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragging = false
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let url = retrieveJSONFileURL(sender) else {
            return false
        }

        dropHereView.isHidden = true
        onFileURLDropped.send(url)

        return true
    }

    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        isDragging = false
    }

    // MARK: Private

    @IBOutlet private var dropHereView: NSView!

    private var isDragging = false {
        didSet {
            needsDisplay = true
        }
    }

    private func shouldAllowDrop(_ draggingInfo: NSDraggingInfo) -> Bool {
        retrieveJSONFileURL(draggingInfo) != nil
    }

    private func retrieveJSONFileURL(_ draggingInfo: NSDraggingInfo) -> URL? {
        let pboard = draggingInfo.draggingPasteboard
        let klass = [NSURL.self]

        guard
            pboard.canReadObject(forClasses: klass, options: nil),
            let urls = pboard.readObjects(forClasses: klass, options: nil) as? [URL]
        else {
            return nil
        }

        // not support multiple files
        let filtered = urls.filter { $0.pathExtension == "json" }
        return filtered.count == 1 ? filtered.first! : nil
    }
}
