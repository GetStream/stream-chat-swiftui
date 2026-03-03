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

            SlideToCancelLabel(location: location)
                .opacity(opacityForSlideToCancel)
                .animation(.easeInOut(duration: 0.2), value: location.x)
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

/// Interactive slide-to-cancel label with position animation and gradient shimmer.
private struct SlideToCancelLabel: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    let location: CGPoint

    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        HStack(spacing: 4) {
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
                .overlay(shimmerOverlay)
                .mask(
                    Text(L10n.Composer.Recording.slideToCancel)
                        .font(fonts.body)
                )
            Image(systemName: "chevron.left")
                .font(.system(size: 20))
                .foregroundColor(Color(colors.textTertiary))
        }
        .offset(x: slideOffset)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: location.x)
        .onAppear {
            withAnimation(
                .linear(duration: 1.8)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerPhase = 1
            }
        }
    }

    private var slideOffset: CGFloat {
        min(0, location.x)
    }

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width * 0.4
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.5), location: 0.4),
                    .init(color: .white.opacity(0.8), location: 0.5),
                    .init(color: .white.opacity(0.5), location: 0.6),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width)
            .offset(x: geo.size.width - (geo.size.width + width) * shimmerPhase)
        }
    }
}

/// Floating lock button shown above the recording bar while recording.
///
/// The user drags up to lock the recording into hands-free mode.
/// The icon animates from lock.open to lock.fill as the user approaches the lock threshold.
struct LockView: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    /// Drag translation (y negative = dragging up). Used to interpolate icon from unlocked to locked.
    var dragLocation: CGPoint = .zero

    private var lockProgress: CGFloat {
        guard dragLocation.y < 0 else { return 0 }
        return min(1, -dragLocation.y / -RecordingConstants.lockMaxDistance)
    }

    var body: some View {
        VStack(spacing: tokens.spacingXxs) {
            ZStack {
                Image(systemName: "lock.open")
                    .font(.system(size: 20))
                    .opacity(1 - lockProgress)
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .opacity(lockProgress)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: lockProgress)
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
