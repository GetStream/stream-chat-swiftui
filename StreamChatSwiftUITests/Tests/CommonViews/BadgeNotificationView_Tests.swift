//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor
final class BadgeNotificationView_Tests: StreamChatTestCase {
    func test_badgeNotification_allVariations_snapshot() {
        let view = BadgeNotificationVariationsView()
            .applySize(CGSize(width: 500, height: 700))

        AssertSnapshot(view, variants: [.defaultLight, .defaultDark])
    }
}

// MARK: - Snapshot Helpers

private struct BadgeNotificationVariationsView: View {
    private let types = BadgeNotificationType.allCases
    private let sizes = BadgeNotificationSize.allCases
    private let counts = [1, 3, 42, 999]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(types, id: \.rawValue) { type in
                    typeSection(type: type)
                }
            }
            .padding(24)
        }
    }

    private func typeSection(type: BadgeNotificationType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type.rawValue)
                .font(.title3.weight(.semibold))

            ForEach(sizes, id: \.rawValue) { size in
                VStack(alignment: .leading, spacing: 8) {
                    Text(size.rawValue)
                        .font(.headline)

                    HStack(spacing: 12) {
                        ForEach(counts, id: \.self) { count in
                            BadgeNotificationView(
                                count: count,
                                type: type,
                                size: size
                            )
                        }
                    }
                }
            }
        }
    }
}
