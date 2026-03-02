//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Defines the placement of the typing indicator.
public enum TypingIndicatorPlacement {
    /// Typing indicator is shown in the navigation bar.
    case navigationBar
    /// Typing indicator is shown inline in the message list.
    case inline
    /// Typing indicator is shown in the message list, and also in the navigation bar
    /// when the message list typing indicator is not visible (e.g. user scrolled up).
    case automatic
}
