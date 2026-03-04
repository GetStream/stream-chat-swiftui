//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import UIKit

struct RecordingWaveform: UIViewRepresentable {
    var isRecording: Bool
    var duration: TimeInterval
    var currentTime: TimeInterval
    var waveform: [Float]
    var onSliderChanged: (TimeInterval) -> Void = { _ in }
    var onSliderTapped: () -> Void = {}
    
    func makeUIView(context: Context) -> WaveformView {
        let view = WaveformView()
        view.onSliderChanged = onSliderChanged
        view.onSliderTapped = onSliderTapped
        view.applyCustomSliderThumb()
        updateContent(for: view)
        return view
    }
    
    func updateUIView(_ uiView: WaveformView, context: Context) {
        uiView.onSliderChanged = onSliderChanged
        uiView.onSliderTapped = onSliderTapped
        updateContent(for: uiView)
    }
    
    private func updateContent(for view: WaveformView) {
        view.content = .init(
            isRecording: isRecording,
            duration: duration,
            currentTime: currentTime,
            waveform: waveform
        )
        view.applyCustomSliderThumb()
        view.slider.isUserInteractionEnabled = !isRecording
    }
}
