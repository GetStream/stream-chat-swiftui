//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Nuke
import NukeUI
import SwiftUI

extension LazyImage {
    
    public init(imageURL: URL?) where Content == NukeUI.Image {
        #if COCOAPODS
        self.init(source: imageURL)
        #else
        self.init(url: imageURL, resizingMode: .aspectFill)
        #endif
    }
    
    public init(imageURL: URL?, @ViewBuilder content: @escaping (LazyImageState) -> Content) {
        #if COCOAPODS
        self.init(source: imageURL, content: content)
        #else
        self.init(url: imageURL, content: content)
        #endif
    }
}
