//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

/// Standard sizes for avatar views.
public enum AvatarSize {
    /// The 2XL avatar size (64 points).
    @MainActor public static var extraExtraLarge: CGFloat = 64
    /// The extra large avatar size (64 points).
    @MainActor public static var extraLarge: CGFloat = 48
    /// The large avatar size (40 points).
    @MainActor public static var large: CGFloat = 40
    /// The medium avatar size (32 points).
    @MainActor public static var medium: CGFloat = 32
    /// The small avatar size (24 points).
    @MainActor public static var small: CGFloat = 24
    /// The extra small avatar size (20 points).
    @MainActor public static var extraSmall: CGFloat = 20
    
    @MainActor static var sizeClassExtraExtraLarge: PartialRangeFrom<CGFloat> { AvatarSize.extraExtraLarge... }
    @MainActor static var sizeClassExtraLarge: Range<CGFloat> { AvatarSize.extraLarge..<AvatarSize.extraExtraLarge }
    @MainActor static var sizeClassLarge: Range<CGFloat> { AvatarSize.large..<AvatarSize.extraLarge }
    @MainActor static var sizeClassMedium: Range<CGFloat> { AvatarSize.medium..<AvatarSize.large }
    @MainActor static var sizeClassSmall: Range<CGFloat> { AvatarSize.small..<AvatarSize.medium }
    @MainActor static var sizeClassExtraSmall: PartialRangeUpTo<CGFloat> { ..<AvatarSize.small }
    
    @MainActor static var standardSizes: [CGFloat] { [AvatarSize.extraExtraLarge, AvatarSize.extraLarge, AvatarSize.large, AvatarSize.medium, AvatarSize.small, AvatarSize.extraSmall] }
}
