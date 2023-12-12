//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct LockedView: View {
    @Injected(\.colors) var colors
    
    @Binding var recordingState: RecordingState
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            HStack {
                if recordingState == .locked {
                    Image(systemName: "mic")
                        .foregroundColor(.red)
                } else {
                    Button {
                        
                    } label: {
                        Image(systemName: "play")
                    }
                }
                Text("00:00")
                    .font(.caption)
                    .foregroundColor(Color(colors.textLowEmphasis))
                Spacer()
            }
            .padding(.horizontal, 8)

            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "trash")
                }

                Spacer()
                
                if recordingState == .locked {
                    Button {
                        recordingState = .stopped
                    } label: {
                        Image(systemName: "stop.circle")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(colors.background))
        .offset(y: -20)
        .overlay(
            recordingState == .locked ? TopRightView {
                Image(systemName: "lock")
                    .padding(.all, 8)
                    .background(Color(colors.background6))
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .offset(y: -66)
                    .padding(.all, 4)
            }
            : nil
        )
    }
}
