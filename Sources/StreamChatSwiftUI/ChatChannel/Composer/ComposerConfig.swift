//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Config for customizing the composer.
public struct ComposerConfig {

    public var inputViewMinHeight: CGFloat
    public var inputViewMaxHeight: CGFloat
    public var inputFont: UIFont
    public var adjustMessageOnSend: (String) -> (String)
    public var adjustMessageOnRead: (String) -> (String)

    public init(
        inputViewMinHeight: CGFloat = 38,
        inputViewMaxHeight: CGFloat = 76,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        adjustMessageOnSend: @escaping (String) -> (String) = { $0 },
        adjustMessageOnRead: @escaping (String) -> (String) = { $0 }
    ) {
        self.inputViewMinHeight = inputViewMinHeight
        self.inputViewMaxHeight = inputViewMaxHeight
        self.inputFont = inputFont
        self.adjustMessageOnSend = adjustMessageOnSend
        self.adjustMessageOnRead = adjustMessageOnRead
    }
}
