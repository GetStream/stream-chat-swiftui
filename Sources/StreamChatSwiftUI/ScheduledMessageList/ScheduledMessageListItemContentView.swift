//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// The layout of a scheduled messages list row.
struct ScheduledMessageListItemContentView<Avatar: View>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.tokens) private var tokens
    @ScaledMetric(relativeTo: .subheadline) private var iconScale: CGFloat = 1

    let sendAtText: String
    let channelName: String
    let previewIcon: UIImage?
    let previewText: String
    let status: ScheduledMessageListItemStatus?
    @ViewBuilder let avatar: () -> Avatar

    var body: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXs) {
            Text(sendAtText)
                .font(fonts.subheadline)
                .foregroundColor(Color(isFailed ? colors.textDisabled : colors.textTertiary))
                .lineLimit(1)
            HStack(alignment: .top, spacing: tokens.spacingSm) {
                avatar()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: tokens.spacingXs) {
                    VStack(alignment: .leading, spacing: tokens.spacingXxs) {
                        Text(channelName)
                            .font(fonts.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(colors.textTertiary))
                        HStack(spacing: tokens.spacingXxs) {
                            ChannelItemAttachmentIcon(image: previewIcon)
                            Text(previewText)
                        }
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textPrimary))
                    }
                    .lineLimit(1)
                    .padding(.vertical, tokens.spacingXxxs)
                    statusView
                }
            }
        }
        .padding(.horizontal, tokens.spacingXxs + tokens.spacingMd)
        .padding(.vertical, tokens.spacingMd)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var isFailed: Bool {
        if case .failed = status { true } else { false }
    }

    @ViewBuilder private var statusView: some View {
        switch status {
        case let .failed(text):
            HStack(alignment: .top, spacing: tokens.spacingXxs) {
                Image(uiImage: images.exclamationTriangleFill)
                    .customizable()
                    .frame(width: tokens.iconSizeSm * iconScale, height: tokens.iconSizeSm * iconScale)
                    .padding(.vertical, tokens.spacingXxxs)
                    .accessibilityHidden(true)
                Text(text)
                    .font(fonts.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(Color(colors.accentError))
        case let .inProgress(text):
            HStack(spacing: tokens.spacingXxs) {
                LoadingSpinnerView(size: LoadingSpinnerSize.extraSmall)
                Text(text)
                    .font(fonts.subheadline)
                    .foregroundColor(Color(colors.textTertiary))
            }
        case nil:
            EmptyView()
        }
    }
}
