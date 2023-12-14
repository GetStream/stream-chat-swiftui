//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct LockedView: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    @ObservedObject var viewModel: MessageComposerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            HStack {
                if viewModel.recordingState == .locked {
                    Image(systemName: "mic")
                        .foregroundColor(.red)
                } else {
                    Button {
                        
                    } label: {
                        Image(systemName: "play")
                    }
                }
                Text(utils.videoDurationFormatter.format(viewModel.audioRecordingInfo.duration) ?? "")
                    .font(.caption)
                    .foregroundColor(Color(colors.textLowEmphasis))
                RecordingWaveform(
                    duration: viewModel.audioRecordingInfo.duration,
                    currentTime: viewModel.audioRecordingInfo.duration,
                    waveform: viewModel.audioRecordingInfo.waveform
                )
                Spacer()
            }
            .padding(.horizontal, 8)

            HStack {
                Button {
                    viewModel.stopRecording()
                    viewModel.audioRecordingInfo = .initial
                } label: {
                    Image(systemName: "trash")
                }

                Spacer()
                
                if viewModel.recordingState == .locked {
                    Button {
                        viewModel.recordingState = .stopped
                        viewModel.stopRecording()
                    } label: {
                        Image(systemName: "stop.circle")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                
                Button {
                    viewModel.stopRecording()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(colors.background))
        .offset(y: -20)
        .overlay(
            viewModel.recordingState == .locked ? TopRightView {
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
