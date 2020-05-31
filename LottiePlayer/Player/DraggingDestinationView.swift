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
    let droppedFileURL = PassthroughSubject<URL, Never>()

    private var isDragging: Bool = false
    var isLabelHidden: Bool = false {
        didSet {
            label.isHidden = isLabelHidden
        }
    }
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Dragging")
    @IBOutlet private weak var label: NSTextField!

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

    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        retrieveJSONFileURL(draggingInfo) != nil
    }

    // MARK: - NSDraggingDestination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        os_log(.default, log: log, "%@", #function)

        guard shouldAllowDrag(sender) else { return [] }

        // Show highlight
        isDragging = true
        needsDisplay = true
        return [.generic]
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        os_log(.default, log: log, "%@", #function)

        isDragging = false
        needsDisplay = true
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        os_log(.default, log: log, "%@", #function)

        isDragging = false
        needsDisplay = true

        guard let url = retrieveJSONFileURL(sender) else {
            return false
        }

        // Do something
        os_log(.default, log: log, "url: %@", url.absoluteString)
        label.isHidden = true
        droppedFileURL.send(url)
        return true
    }

    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        os_log(.default, log: log, "%@", #function)
        // Not working?
    }

    // MARK: - private

    private func retrieveJSONFileURL(_ draggingInfo: NSDraggingInfo) -> URL? {
        let pboard = draggingInfo.draggingPasteboard
        let klass = [NSURL.self]

        guard pboard.canReadObject(forClasses: klass, options: nil),
              let urls = pboard.readObjects(forClasses: klass, options: nil) as? [URL] else {
            return nil
        }

        // not support multiple files
        let filterd = urls.filter { $0.pathExtension == "json" }
        return filterd.count == 1 ? filterd.first! : nil
    }
}
