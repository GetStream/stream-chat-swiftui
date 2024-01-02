//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Provides access to fonts used in the SDK.
public struct Fonts {
    public init() {
        // Public init.
    }

    public var caption1 = Font.caption
    public var footnoteBold = Font.footnote.bold()
    public var footnote = Font.footnote
    public var subheadline = Font.subheadline
    public var subheadlineBold = Font.subheadline.bold()
    public var body = Font.body
    public var bodyBold = Font.body.bold()
    public var bodyItalic = Font.body.italic()
    public var headline = Font.headline
    public var headlineBold = Font.headline.bold()
    public var title = Font.title
    public var title3 = Font.title3
    public var emoji = Font.system(size: 50)
}
