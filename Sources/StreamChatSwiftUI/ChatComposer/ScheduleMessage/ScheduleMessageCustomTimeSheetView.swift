//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

/// The sheet for picking a custom date and time to send a scheduled message at.
public struct ScheduleMessageCustomTimeSheetView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.tokens) private var tokens
    @Injected(\.utils) private var utils

    @Environment(\.timeZone) private var timeZone

    @StateObject private var viewModel: ScheduleMessageCustomTimeViewModel

    private let factory: Factory
    private let preview: ScheduleMessagePreview
    private let title: String
    private let onDismiss: @MainActor () -> Void

    /// Creates the sheet.
    /// - Parameters:
    ///   - factory: The view factory to create the icon and the thumbnail of the message preview.
    ///   - options: The options of the sheet.
    ///   - viewModel: The view model of the sheet. It is created from the options when `nil`.
    public init(
        factory: Factory,
        options: ScheduleMessageCustomTimeSheetOptions,
        viewModel: ScheduleMessageCustomTimeViewModel? = nil
    ) {
        self.factory = factory
        preview = options.preview
        title = options.scheduledMessage == nil ? L10n.Composer.ScheduleMessage.title : L10n.ScheduledMessages.Reschedule.title
        onDismiss = options.onDismiss
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ScheduleMessageCustomTimeViewModel(
                channel: options.channel,
                usage: options.usage,
                initialDate: options.scheduledMessage?.scheduledAt,
                validate: options.validate,
                onSchedule: options.onSchedule
            )
        )
    }

    public var body: some View {
        SheetView(
            title: title,
            estimatedContentHeight: 540,
            onClose: onDismiss,
            onConfirm: { viewModel.confirm() },
            confirmDisabled: !viewModel.canConfirm
        ) {
            VStack(spacing: tokens.spacingMd) {
                previewView
                if let errorText = viewModel.errorText {
                    NotificationView(style: .error, title: errorText)
                        .accessibilityIdentifier("ScheduleMessageCustomTimeError")
                }
                DatePicker(
                    title,
                    selection: $viewModel.date,
                    in: viewModel.dateRange,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .accentColor(Color(colors.accentPrimary))
                NotificationView(
                    style: .info,
                    title: countText ?? timeZoneText,
                    description: countText == nil ? nil : timeZoneText
                )
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.top, tokens.spacingXs)
        }
        .accessibilityIdentifier("ScheduleMessageCustomTimeSheetView")
    }

    private var previewView: some View {
        ReferenceMessageView(
            title: preview.title,
            subtitle: preview.subtitle,
            outgoing: true,
            iconPreview: {
                if let icon = preview.icon {
                    factory.makeMessageAttachmentPreviewIconView(
                        options: MessageAttachmentPreviewIconViewOptions(icon: icon)
                    )
                }
            },
            attachmentPreview: {
                factory.makeMessageAttachmentPreviewThumbnailView(
                    options: MessageAttachmentPreviewViewOptions(thumbnail: preview.thumbnail)
                )
            }
        )
        .padding(tokens.spacingXs)
        .modifier(ReferenceMessageViewBackgroundModifier(backgroundColor: colors.chatBackgroundOutgoing.toColor))
        .fixedSize(horizontal: false, vertical: true)
        .frame(minHeight: 56)
    }

    private var countText: String? {
        guard let usage = viewModel.usage, let limit = usage.channelLimit else { return nil }
        return L10n.Composer.ScheduleMessage.Note.count(usage.channelCount, limit)
    }

    private var timeZoneText: String {
        L10n.Composer.ScheduleMessage.Note.timeZone(utils.scheduledMessagesConfig.dateFormatter.formatTimeZone(timeZone))
    }
}
