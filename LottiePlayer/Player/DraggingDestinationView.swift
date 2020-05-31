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

    var isLabelHidden: Bool = false {
        didSet {
            label.isHidden = isLabelHidden
        }
    }

    private var isDragging: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Dragging")
    private let logType: OSLogType = .debug

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

    private func shouldAllowDrop(_ draggingInfo: NSDraggingInfo) -> Bool {
        retrieveJSONFileURL(draggingInfo) != nil
    }

    // MARK: - NSDraggingDestination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        os_log(logType, log: log, "%@", #function)
        guard shouldAllowDrop(sender) else { return [] }

        isDragging = true
        return [.generic]
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        os_log(logType, log: log, "%@", #function)
        isDragging = false
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        os_log(logType, log: log, "%@", #function)
        isDragging = false

        guard let url = retrieveJSONFileURL(sender) else {
            return false
        }

        os_log(logType, log: log, "url: %@", url.absoluteString)
        label.isHidden = true
        droppedFileURL.send(url)
        return true
    }

    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        os_log(logType, log: log, "%@", #function)
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
