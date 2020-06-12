//
//  Document.swift
//  LottiePlayer
//  
//  Created by Mitsuru Nakada on 2020/05/31.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    var content: Content?

    override func makeWindowControllers() {
        super.makeWindowControllers()

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let id = NSStoryboard.SceneIdentifier("WindowController")
        guard let windowController = storyboard.instantiateController(withIdentifier: id) as? NSWindowController else { return }
        addWindowController(windowController)

        if let contentVC = windowController.contentViewController {
            contentVC.representedObject = content
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        content = Content(url: url)
    }
}
