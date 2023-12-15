//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct LockedView: View {
    @Injected(\.colors) var colors
    @Injected(\.utils) var utils
    
    @ObservedObject var viewModel: MessageComposerViewModel
    @State var isPlaying = false
    @StateObject var voiceRecordingHandler = VoiceRecordingHandler()
    
    private var player: AudioPlaying {
        utils.audioPlayer
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            HStack {
                if viewModel.recordingState == .locked {
                    Image(systemName: "mic")
                        .foregroundColor(.red)
                } else {
                    Button {
                        handlePlayTap()
                    } label: {
                        Image(systemName: isPlaying ? "pause" : "play")
                    }
                }
                Text(utils.videoDurationFormatter.format(viewModel.audioRecordingInfo.duration) ?? "")
                    .font(.caption)
                    .foregroundColor(Color(colors.textLowEmphasis))
                RecordingWaveform(
                    duration: viewModel.audioRecordingInfo.duration,
                    currentTime: viewModel.recordingState == .stopped ?
                        voiceRecordingHandler.context.currentTime :
                        viewModel.audioRecordingInfo.duration,
                    waveform: viewModel.audioRecordingInfo.waveform
                )
                Spacer()
            }
            .padding(.horizontal, 8)

            HStack {
                Button {
                    viewModel.recordingState = .initial
                    viewModel.audioRecordingInfo = .initial
                    viewModel.stopRecording()
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
                    if viewModel.recordingState == .stopped {
                        if let pending = viewModel.pendingAudioRecording {
                            viewModel.addedVoiceRecordings.append(pending)
                            viewModel.pendingAudioRecording = nil
                            viewModel.audioRecordingInfo = .initial
                            viewModel.recordingState = .initial
                        }
                    } else {
                        viewModel.stopRecording()
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
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
        .onAppear {
            player.subscribe(voiceRecordingHandler)
        }
        .onReceive(voiceRecordingHandler.$context, perform: { value in
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
    }
    
    private func handlePlayTap() {
        if isPlaying {
            player.pause()
        } else if let url = viewModel.pendingAudioRecording?.url {
            player.loadAsset(from: url)
        }
        isPlaying.toggle()
    }
}
