//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatCommonUI
import SwiftUI

public enum AvatarSize {
    @MainActor public static var large: CGFloat = 40
    @MainActor public static var medium: CGFloat = 32
    @MainActor public static var small: CGFloat = 24
    @MainActor public static var extraSmall: CGFloat = 20
    
    @MainActor static var largeSizeClass: PartialRangeFrom<CGFloat> { AvatarSize.large... }
    @MainActor static var mediumSizeClass: Range<CGFloat> { AvatarSize.medium..<AvatarSize.large }
    @MainActor static var smallSizeClass: Range<CGFloat> { AvatarSize.small..<AvatarSize.medium }
    @MainActor static var extraSmallSizeClass: PartialRangeUpTo<CGFloat> { ..<AvatarSize.small }
    
    @MainActor static var standardSizes: [CGFloat] { [AvatarSize.large, AvatarSize.medium, AvatarSize.small, AvatarSize.extraSmall] }
}
