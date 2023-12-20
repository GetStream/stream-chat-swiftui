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
    @State var showLockedIndicator = true
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
                RecordingDurationView(
                    duration: showContextTime ?
                        voiceRecordingHandler.context.currentTime : viewModel.audioRecordingInfo.duration
                )
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
                    withAnimation {
                        viewModel.discardRecording()
                    }
                } label: {
                    Image(systemName: "trash")
                }

                Spacer()
                
                if viewModel.recordingState == .locked {
                    Button {
                        withAnimation {
                            viewModel.previewRecording()
                        }
                    } label: {
                        Image(systemName: "stop.circle")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                
                Button {
                    withAnimation {
                        viewModel.confirmRecording()
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
        .offset(y: -20)
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
        .overlay(
            showLockedIndicator ? TopRightView { LockedRecordIndicator() } : nil
        )
        .onAppear {
            player.subscribe(voiceRecordingHandler)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showLockedIndicator = false
            }
        }
        .onReceive(voiceRecordingHandler.$context, perform: { value in
            if value.state == .stopped || value.state == .paused {
                isPlaying = false
            } else if value.state == .playing {
                isPlaying = true
            }
        })
    }
    
    private var showContextTime: Bool {
        voiceRecordingHandler.context.currentTime > 0
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

struct LockedRecordIndicator: View {
    @Injected(\.colors) var colors
    
    var body: some View {
        Image(systemName: "lock")
            .padding(.all, 8)
            .background(Color(colors.background6))
            .foregroundColor(.blue)
            .clipShape(Circle())
            .offset(y: -66)
            .padding(.all, 4)
    }
}
