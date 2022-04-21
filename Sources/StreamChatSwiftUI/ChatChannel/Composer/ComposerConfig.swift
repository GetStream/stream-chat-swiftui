//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Config for customizing the composer.
public struct ComposerConfig {
    
    public var inputViewMinHeight: CGFloat
    public var inputFont: UIFont
    
    public init(
        inputViewMinHeight: CGFloat = 38,
        inputFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    ) {
        self.inputViewMinHeight = inputViewMinHeight
        self.inputFont = inputFont
    }
}
