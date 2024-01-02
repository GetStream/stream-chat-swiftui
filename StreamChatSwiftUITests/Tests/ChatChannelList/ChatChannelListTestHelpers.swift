//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatSwiftUI
import UIKit

/// The default view controller size. Simulates an iPhone in portrait mode.
let defaultScreenSize = CGSize(width: 360, height: 700)

extension ChannelAlertType: Equatable {

    public static func == (lhs: ChannelAlertType, rhs: ChannelAlertType) -> Bool {
        if case let .deleteChannel(channel1) = lhs,
           case let .deleteChannel(channel2) = rhs {
            return channel1 == channel2
        }

        if case .error = lhs, case .error = rhs {
            return true
        }

        return false
    }
}

extension ChannelPopupType: Equatable {

    public static func == (lhs: ChannelPopupType, rhs: ChannelPopupType) -> Bool {
        if case let .moreActions(channel1) = lhs,
           case let .moreActions(channel2) = rhs {
            return channel1 == channel2
        }

        return false
    }
}
