//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChatSwiftUI
import SwiftUI
import XCTest

@MainActor
final class StreamButton_Tests: StreamChatTestCase {
    private let snapshotSize = CGSize(width: 800, height: 1400)

    func test_streamButton_iconOnlyVariations_snapshot() {
        let view = StreamButtonVariationsView(mode: .iconOnly)
            .applySize(CGSize(width: 400, height: 1400))

        AssertSnapshot(view, variants: [.defaultLight], size: snapshotSize)
    }

    func test_streamButton_iconAndTextVariations_snapshot() {
        let view = StreamButtonVariationsView(mode: .withText)
            .applySize(CGSize(width: 700, height: 1400))

        AssertSnapshot(view, variants: [.defaultLight], size: snapshotSize)
    }
}

private enum StreamButtonSnapshotContentMode: String, CaseIterable {
    case withText = "Icon + Text"
    case iconOnly = "Icon Only"
}

private enum StreamButtonSnapshotState: String, CaseIterable {
    case enabled = "Enabled"
    case disabled = "Disabled"
}

private struct StreamButtonVariationsView: View {
    let mode: StreamButtonSnapshotContentMode

    private let roles = StreamButtonRole.allCases
    private let styles = StreamButtonVisualStyle.allCases
    private let sizes = StreamButtonSize.allCases
    private let states = StreamButtonSnapshotState.allCases

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                modeSection(mode: mode)
            }
            .padding(24)
        }
    }

    private func modeSection(mode: StreamButtonSnapshotContentMode) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(mode.rawValue)
                .font(.title3.weight(.semibold))

            ForEach(roles, id: \.rawValue) { role in
                ForEach(sizes, id: \.rawValue) { size in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(role.rawValue), \(size.rawValue)")
                            .font(.headline)

                        ForEach(states, id: \.rawValue) { state in
                            HStack(alignment: .center, spacing: 12) {
                                Text(state.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 90, alignment: .leading)

                                ForEach(styles, id: \.rawValue) { style in
                                    button(
                                        role: role,
                                        style: style,
                                        size: size,
                                        mode: mode,
                                        state: state
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func button(
        role: StreamButtonRole,
        style: StreamButtonVisualStyle,
        size: StreamButtonSize,
        mode: StreamButtonSnapshotContentMode,
        state: StreamButtonSnapshotState
    ) -> some View {
        StreamButton(
            icon: Image(systemName: "plus"),
            text: mode == .withText ? style.rawValue : nil,
            role: role,
            style: style,
            size: size,
            action: {}
        )
        .disabled(state == .disabled)
    }
}
