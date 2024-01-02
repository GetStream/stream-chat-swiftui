//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

extension UIView {
    func withAccessibilityIdentifier(identifier: String) -> Self {
        accessibilityIdentifier = identifier
        return self
    }
}

extension NSObject {
    var classIdentifier: String {
        "\(type(of: self))"
    }
}

// Protocol that provides accessibility features
protocol AccessibilityView {
    // Identifier for view
    var accessibilityViewIdentifier: String { get }

    // This function is called once the view is being added to the view hierarchy
    func setAccessibilityIdentifier()
}

extension AccessibilityView where Self: UIView {
    var accessibilityViewIdentifier: String {
        classIdentifier
    }

    func setAccessibilityIdentifier() {
        accessibilityIdentifier = accessibilityViewIdentifier
    }
}

#endif
