//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import UIKit

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }

    var bold: UIFont {
        withTraits(traits: .traitBold)
    }

    var italic: UIFont {
        withTraits(traits: .traitItalic)
    }
}
