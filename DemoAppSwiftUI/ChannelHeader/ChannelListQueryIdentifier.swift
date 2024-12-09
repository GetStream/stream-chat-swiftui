//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

enum ChannelListQueryIdentifier: String, CaseIterable, Identifiable {
    case initial
    case archived
    case pinned
    case unarchivedAndPinnedSorted
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .initial: "Initial Channels"
        case .archived: "Archived Channels"
        case .pinned: "Pinned Channels"
        case .unarchivedAndPinnedSorted: "Sort by Pinned and Ignore Archived Channels"
        }
    }
}
