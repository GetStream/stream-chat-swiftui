//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// The recording bar shown inside the composer input while actively recording.
///
/// Layout: [mic indicator | duration] — [Slide to cancel ‹] — [mic button]
struct RecordingView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    @Injected(\.tokens) var tokens
    @Injected(\.utils) var utils

    var location: CGPoint
    var audioRecordingInfo: AudioRecordingInfo
    var onMicTap: () -> Void

    var body: some View {
        HStack(spacing: tokens.spacingNone) {
            HStack(spacing: tokens.spacingNone) {
                Image(systemName: "mic.fill")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)

                RecordingDurationView(duration: audioRecordingInfo.duration)
            }

            Spacer()

            HStack(spacing: tokens.spacingXxs) {
                Text(L10n.Composer.Recording.slideToCancel)
                    .font(fonts.body)
                    .foregroundColor(.clear)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color(colors.textPrimary),
                                Color(colors.textTertiary)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text(L10n.Composer.Recording.slideToCancel)
                                .font(fonts.body)
                        )
                    )
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundColor(Color(colors.textTertiary))
            }
            .opacity(opacityForSlideToCancel)
            .accessibilityHidden(true)

            Spacer()

            Button {
                onMicTap()
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(colors.textPrimary))
                    .frame(width: 32, height: 32)
                    .background(Color(colors.backgroundCorePressed))
                    .clipShape(Circle())
            }
            .frame(width: 48, height: 48)
            .accessibilityLabel(Text(L10n.Composer.AudioRecording.stop))
        }
        .frame(height: 48)
    }

    private var opacityForSlideToCancel: CGFloat {
        guard location.x < RecordingConstants.cancelMinDistance else { return 1 }
        return 1 - location.x / RecordingConstants.cancelMaxDistance
    }
}

/// Floating lock button shown above the recording bar while recording.
///
/// The user drags up to lock the recording into hands-free mode.
struct LockView: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    var body: some View {
        VStack(spacing: tokens.spacingXxs) {
            Image(systemName: "lock.open")
                .font(.system(size: 20))
            Image(systemName: "chevron.up")
                .font(.system(size: 20))
        }
        .foregroundColor(Color(colors.textSecondary))
        .padding(10)
        .frame(width: 40)
        .background(Color(colors.backgroundElevationElevation1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(colors.borderCoreDefault), lineWidth: 1)
        )
        .shadow(
            color: Color(tokens.lightElevation3.color),
            radius: tokens.lightElevation3.blur / 2,
            x: tokens.lightElevation3.x,
            y: tokens.lightElevation3.y
        )
    }
}
