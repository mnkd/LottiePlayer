//
//  Content.swift
//  LottiePlayer
//
//  Created by Mitsuru Nakada on 2020/05/31.
//  Copyright © 2020 Mitsuru Nakada. All rights reserved.
//

import Foundation

final class Content: NSObject {
    // MARK: Lifecycle

    init(url: URL) {
        self.url = url
    }

    // MARK: Internal

    let url: URL
}
