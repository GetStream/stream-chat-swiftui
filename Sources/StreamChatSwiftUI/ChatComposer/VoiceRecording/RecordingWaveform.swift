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
        let thumbImage = roundedSliderThumbImage()
        view.slider.setThumbImage(thumbImage, for: .normal)
        view.slider.setThumbImage(thumbImage, for: .highlighted)
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
        let thumbImage = roundedSliderThumbImage()
        view.slider.setThumbImage(thumbImage, for: .normal)
        view.slider.setThumbImage(thumbImage, for: .highlighted)
        view.slider.isUserInteractionEnabled = !isRecording
    }

    private func roundedSliderThumbImage() -> UIImage {
        let colors = InjectedValues[\.colors]
        let thumbDiameter: CGFloat = 12
        let borderWidth: CGFloat = 1
        let shadowBlur: CGFloat = 6
        let shadowOffsetY: CGFloat = 2
        let canvasSize = CGSize(
            width: thumbDiameter + shadowBlur * 2,
            height: thumbDiameter + shadowBlur * 2 + shadowOffsetY
        )
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        return renderer.image { ctx in
            let cgContext = ctx.cgContext
            let thumbRect = CGRect(
                x: (canvasSize.width - thumbDiameter) / 2,
                y: (canvasSize.height - thumbDiameter - shadowOffsetY) / 2,
                width: thumbDiameter,
                height: thumbDiameter
            )
            let path = UIBezierPath(ovalIn: thumbRect)

            cgContext.setShadow(
                offset: CGSize(width: 0, height: shadowOffsetY),
                blur: shadowBlur,
                color: UIColor.black.withAlphaComponent(0.14).cgColor
            )
            colors.accentPrimary.setFill()
            path.fill()

            cgContext.setShadow(offset: .zero, blur: 0, color: nil)
            UIColor.white.setStroke()
            path.lineWidth = borderWidth
            path.stroke()
        }
    }
}
