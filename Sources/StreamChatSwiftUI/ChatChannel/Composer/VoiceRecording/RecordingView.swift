//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct RecordingView: View {
    
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    var location: CGPoint
    var audioRecordingInfo: AudioRecordingInfo
    
    private let initialLockOffset: CGFloat = -70
    
    var body: some View {
        HStack {
            Image(systemName: "mic")
                .foregroundColor(.red)
            Text(utils.videoDurationFormatter.format(audioRecordingInfo.duration) ?? "")
                .font(.caption)
                .foregroundColor(Color(colors.textLowEmphasis))
            
            Spacer()
            
            Text("Slide to cancel <")
                .foregroundColor(Color(colors.textLowEmphasis))
                .opacity(opacityForSlideToCancel)
            
            Spacer()
            
            Image(systemName: "mic")
                .foregroundColor(.blue)
        }
        .padding(.all, 12)
        .overlay(
            TopRightView {
                LockView()
                    .padding(.all, 4)
                    .offset(y: lockViewOffset)
            }
        )
    }
    
    private var lockViewOffset: CGFloat {
        if location.y > 0 {
            return initialLockOffset
        }
        return initialLockOffset + location.y
    }
    
    private var opacityForSlideToCancel: CGFloat {
        guard location.x < RecordingConstants.cancelMinDistance else { return 1 }
        let opacity = (1 - location.x / RecordingConstants.cancelMaxDistance)
        return opacity
    }
}

struct LockView: View {
    @Injected(\.colors) var colors
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock")
            Image(systemName: "chevron.up")
        }
        .padding(.all, 8)
        .padding(.vertical, 2)
        .foregroundColor(Color(colors.textLowEmphasis))
        .background(Color(colors.background6))
        .cornerRadius(16)
    }
}
