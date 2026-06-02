//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Floating lock button shown above the recording bar while recording.
///
/// Morphs between two visual states with a single smooth animation:
/// - **Unlocked** (capsule): lock.open ↔ lock + chevron.up arrow
/// - **Locked** (circle): lock only, chevron collapses to zero height
public struct VoiceRecordingLockView: View {
    @Injected(\.colors) var colors
    @Injected(\.tokens) var tokens

    var dragLocation: CGPoint = .zero
    var isLocked: Bool = false

    @State private var lockScale: CGFloat = 1.0
    @State private var lockedOpacity: CGFloat = 1.0

    private var lockProgress: CGFloat {
        if isLocked { return 1 }
        guard dragLocation.y < 0 else { return 0 }
        return min(1, -dragLocation.y / -VoiceRecordingConstants.lockMaxDistance)
    }

    private var lockSymbolName: String {
        isLocked || lockProgress >= 0.5 ? "lock" : "lock.open"
    }
    
    public init(
        dragLocation: CGPoint = .zero,
        isLocked: Bool = false
    ) {
        self.dragLocation = dragLocation
        self.isLocked = isLocked
    }

    public var body: some View {
        VStack(spacing: isLocked ? 0 : tokens.spacingXxs) {
            lockIcon
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: lockProgress)

            Image(systemName: "chevron.up")
                .font(.system(size: 20))
                .opacity(isLocked ? 0 : 1)
                .frame(height: isLocked ? 0 : nil)
                .clipped()
        }
        .foregroundColor(Color(colors.textSecondary))
        .padding(10)
        .frame(width: 40)
        .background(Color(colors.backgroundCoreElevation1))
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
        .scaleEffect(lockScale)
        .opacity(isLocked ? lockedOpacity : 1)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: isLocked)
        .onChange(of: isLocked) { locked in
            guard locked else {
                lockedOpacity = 1
                return
            }
            lockScale = 1.15
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                lockScale = 1.0
            }
            lockedOpacity = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    lockedOpacity = 0
                }
            }
        }
    }

    @ViewBuilder
    private var lockIcon: some View {
        if #available(iOS 17, *) {
            Image(systemName: lockSymbolName)
                .font(.system(size: 20))
                .contentTransition(.symbolEffect(.replace))
                .animation(.spring(response: 0.32, dampingFraction: 0.76), value: lockProgress)
        } else {
            ZStack {
                Image(systemName: "lock.open")
                    .font(.system(size: 20))
                    .opacity(1 - lockProgress)
                Image(systemName: "lock")
                    .font(.system(size: 20))
                    .opacity(lockProgress)
            }
        }
    }
}
