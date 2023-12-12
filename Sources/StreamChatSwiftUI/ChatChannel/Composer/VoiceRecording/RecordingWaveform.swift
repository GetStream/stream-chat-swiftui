//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct RecordingWaveform: UIViewRepresentable {
    var duration: TimeInterval
    var currentTime: TimeInterval
    var waveform: [Float]
    
    func makeUIView(context: Context) -> WaveformView {
        let view = WaveformView()
        updateContent(for: view)
        return view
    }
    
    func updateUIView(_ uiView: WaveformView, context: Context) {
        updateContent(for: uiView)
    }
    
    private func updateContent(for view: WaveformView) {
        view.content = .init(
            isRecording: true,
            duration: duration,
            currentTime: currentTime,
            waveform: waveform
        )
    }
}
