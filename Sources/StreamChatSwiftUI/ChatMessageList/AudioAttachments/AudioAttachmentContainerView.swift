//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import StreamChat
import SwiftUI

/// Displays the audio file attachments of a message.
public struct AudioAttachmentContainerView<Factory: ViewFactory>: View {
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    let factory: Factory
    let options: AudioAttachmentViewOptions

    @ObservedObject var handler: AudioSessionHandler

    public init(factory: Factory, options: AudioAttachmentViewOptions) {
        self.factory = factory
        self.options = options
        _handler = ObservedObject(wrappedValue: InjectedValues[\.utils].audioSessionHandler)
    }

    private var message: ChatMessage { options.message }

    private var width: CGFloat {
        min(options.availableWidth, utils.messageListConfig.attachmentPreviewWidth)
    }

    public var body: some View {
        VStack(spacing: tokens.spacingXxxs) {
            ForEach(message.audioAttachments) { attachment in
                AudioAttachmentView(
                    handler: handler,
                    attachment: attachment,
                    message: message,
                    isSentByCurrentUser: message.isSentByCurrentUser
                )
                .modifier(
                    factory.styles.makeMessageAttachmentItemViewModifier(
                        options: MessageAttachmentItemViewModifierOptions(
                            message: message,
                            isFirst: options.isFirst,
                            attachmentType: .audio
                        )
                    )
                )
            }
        }
        .frame(width: width, alignment: message.isRightAligned ? .trailing : .leading)
        .audioPlaybackQueue(
            handler: handler,
            urls: message.audioAttachments.map(\.payload.audioURL)
        )
        .accessibilityIdentifier("AudioAttachmentContainerView")
    }
}

struct AudioAttachmentView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils
    @Injected(\.chatClient) var chatClient

    @State private var loadedDuration: TimeInterval?
    @ObservedObject var handler: AudioSessionHandler

    let attachment: ChatMessageAudioAttachment
    let message: ChatMessage
    var isSentByCurrentUser: Bool = false

    private var playbackURL: URL {
        attachment.uploadingState?.localFileURL ?? attachment.payload.audioURL
    }

    private var isActive: Bool { handler.isActive(for: playbackURL) }

    private var isPlaying: Bool { handler.isPlaying && isActive }

    private var isLoading: Bool { isActive && handler.context.state == .loading }

    private var isInteractive: Bool {
        switch attachment.uploadingState?.state {
        case .uploading, .pendingUpload, .uploadingFailed:
            return false
        default:
            return true
        }
    }

    private var payloadDuration: TimeInterval? {
        attachment.payload.duration
            ?? Self.duration(fromRawPayload: message.attachment(with: attachment.id)?.payload)
    }

    private var resolvedDuration: TimeInterval {
        if isActive, handler.context.duration > 0 {
            return handler.context.duration
        }
        if let loadedDuration, loadedDuration > 0 {
            return loadedDuration
        }
        return payloadDuration ?? 0
    }

    private var displayedPlaybackTime: TimeInterval {
        guard isActive, handler.context.state == .playing else { return resolvedDuration }
        return min(max(handler.context.currentTime, 0), resolvedDuration)
    }

    private var currentTime: TimeInterval {
        guard isActive else { return 0 }
        switch handler.context.state {
        case .playing, .paused:
            return min(max(handler.context.currentTime, 0), resolvedDuration)
        default:
            return 0
        }
    }

    var body: some View {
        let knownDuration = payloadDuration
        let url = playbackURL
        return HStack(spacing: tokens.spacingXs) {
            playButton
            fileNameAndMetadata
        }
        .accessibilityElement(children: isInteractive ? .ignore : .combine)
        .accessibilityLabel(resolvedAccessibilityLabel)
        .accessibilityAddTraits(isInteractive ? [.isButton, .startsMediaSession] : [])
        .accessibilityAction {
            guard isInteractive else { return }
            handler.togglePlayback(for: playbackURL)
        }
        .audioPlaybackStateUpdates(handler: handler, url: url)
        .compatibility.task(id: url) { @MainActor in
            guard knownDuration == nil else { return }
            loadedDuration = await AVURLAsset(url: url).loadDuration()
        }
        .accessibilityIdentifier("AudioAttachmentView")
    }

    private var playButton: some View {
        AudioPlaybackButton(
            isPlaying: isPlaying,
            isLoading: isLoading,
            isSentByCurrentUser: isSentByCurrentUser,
            isEnabled: isInteractive
        ) {
            handler.togglePlayback(for: playbackURL)
        }
    }

    private var fileNameAndMetadata: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(attachment.payload.title ?? attachment.payload.audioURL.lastPathComponent)
                    .font(fonts.subheadlineBold)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textPrimary))
                Spacer(minLength: 0)
                fileTypeIcon
            }
            metadataRow
        }
    }

    private var fileTypeIcon: some View {
        Image(uiImage: images.iconAudio)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 19, height: 24)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var metadataRow: some View {
        if let uploadingState = attachment.uploadingState {
            switch uploadingState.state {
            case let .uploading(progress):
                uploadingSubtitle(progress: progress, file: uploadingState.file)
            case .pendingUpload:
                uploadingSubtitle(progress: 0, file: uploadingState.file)
            case .uploadingFailed:
                uploadFailedSubtitle
            default:
                playbackControls
            }
        } else {
            playbackControls
        }
    }

    private var playbackControls: some View {
        HStack(spacing: tokens.spacingXs) {
            Text(utils.videoDurationFormatter.format(displayedPlaybackTime) ?? "")
                .font(fonts.footnote.monospacedDigit())
                .foregroundColor(Color(isPlaying ? colors.accentPrimary : colors.textPrimary))

            PlaybackProgressBar(
                duration: resolvedDuration,
                currentTime: currentTime,
                isPlaying: isPlaying,
                onSeek: { timeInterval in
                    handler.seek(to: timeInterval, loadingFrom: isActive ? nil : playbackURL)
                }
            )
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SwipeToReplyExcludedFrameKey.self,
                        value: [proxy.frame(in: .named("swipeToReply"))]
                    )
                }
            )
        }
    }

    private func uploadingSubtitle(progress: Double, file: AttachmentFile) -> some View {
        HStack(spacing: tokens.spacingXxs) {
            LoadingSpinnerView(
                size: LoadingSpinnerSize.extraSmall,
                progress: Double(progress)
            )
            Text(FileAttachmentDisplayView.uploadProgressText(progress: progress, file: file))
                .font(fonts.footnote)
                .lineLimit(1)
                .foregroundColor(Color(colors.textPrimary))
        }
        .padding(.top, tokens.spacingXxxs)
    }

    private var uploadFailedSubtitle: some View {
        VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
            HStack(spacing: tokens.spacingXxs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: tokens.iconSizeSm, height: tokens.iconSizeSm)
                    .foregroundColor(Color(colors.accentError))
                    .accessibilityHidden(true)
                Text(L10n.Message.Sending.attachmentUploadFailed)
                    .font(fonts.footnote)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textPrimary))
            }
            Button(action: retryUpload) {
                Text(L10n.Message.Sending.attachmentRetryUpload)
                    .font(fonts.footnote)
                    .foregroundColor(Color(colors.textLink))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, tokens.spacingXxxs)
    }

    private func retryUpload() {
        let messageId = attachment.id.messageId
        let cid = attachment.id.cid
        let controller = chatClient.messageController(cid: cid, messageId: messageId)
        controller.resendMessage()
    }

    private var resolvedAccessibilityLabel: String {
        let spokenDuration = resolvedDuration > 0
            ? utils.messageAccessibilityFormatter.duration(from: resolvedDuration)
            : nil
        return utils.messageAccessibilityFormatter.audioLabel(
            for: message,
            metadata: AudioAttachmentAccessibilityMetadata(
                fileName: attachment.payload.title ?? attachment.payload.audioURL.lastPathComponent,
                duration: spokenDuration
            )
        )
    }

    static func duration(fromRawPayload data: Data?) -> TimeInterval? {
        guard
            let data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let value = (json["duration"] as? NSNumber)?.doubleValue,
            value.isFinite,
            value > 0
        else { return nil }
        return value
    }
}

extension AudioAttachmentPayload {
    var duration: TimeInterval? {
        extraData?["duration"].flatMap { value -> TimeInterval? in
            if case let .number(number) = value { return number }
            return nil
        }
    }
}
