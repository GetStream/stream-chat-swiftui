//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The default scheduled message list loading view.
public struct ScheduledMessageListLoadingView: View {
    @Injected(\.colors) private var colors

    public init() {}

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<10) { _ in
                    ScheduledMessageListSkeletonRow()
                        .shimmering(duration: 0.8, delay: 0.1)

                    Divider()
                        .overlay(Color(colors.borderCoreSubtle))
                }
            }
        }
        .disabled(true)
        .accessibilityIdentifier("ScheduledMessageListLoadingView")
    }
}

private struct ScheduledMessageListSkeletonRow: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @ScaledMetric(relativeTo: .subheadline) private var captionBarHeight: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var bodyBarHeight: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacingMd) {
            bar(width: 120, height: captionBarHeight)
            HStack(alignment: .top, spacing: tokens.spacingSm) {
                Circle()
                    .fill(fillColor)
                    .frame(width: AvatarSize.extraLarge, height: AvatarSize.extraLarge)
                VStack(alignment: .leading, spacing: tokens.spacingXs) {
                    bar(width: 96, height: captionBarHeight)
                    bar(width: 260, height: bodyBarHeight)
                }
            }
        }
        .padding(.horizontal, tokens.spacingXxs + tokens.spacingMd)
        .padding(.vertical, tokens.spacingMd)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fillColor: Color {
        Color(colors.backgroundCoreSurfaceDefault)
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(fillColor)
            .frame(maxWidth: width)
            .frame(height: height)
    }
}
