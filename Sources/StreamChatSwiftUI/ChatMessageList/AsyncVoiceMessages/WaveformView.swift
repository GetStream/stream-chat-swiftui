//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI
import UIKit

/// Displays an interactive waveform visualisation of an audio file.
open class WaveformView: UIView {
    @Injected(\.images) var images
    
    open var onSliderChanged: ((TimeInterval) -> Void)?
    open var onSliderTapped: (() -> Void)?
    
    public struct Content: Equatable, Sendable {
        /// When set to `true` the waveform will be updating with the data live (scrolling to the trailing side
        /// as new data arrive).
        public var isRecording: Bool

        /// Whether audio playback is currently active.
        public var isPlaying: Bool

        /// The duration of the Audio file that we are representing.
        public var duration: TimeInterval

        /// The playback's currentTime for the Audio file we are representing.
        public var currentTime: TimeInterval

        /// The waveform's data that will be used to render the visualisation.
        public var waveform: [Float]

        public static let initial = Content(
            isRecording: false,
            isPlaying: false,
            duration: 0,
            currentTime: 0,
            waveform: []
        )

        public init(
            isRecording: Bool,
            isPlaying: Bool = false,
            duration: TimeInterval,
            currentTime: TimeInterval,
            waveform: [Float]
        ) {
            self.isRecording = isRecording
            self.isPlaying = isPlaying
            self.duration = duration
            self.currentTime = currentTime
            self.waveform = waveform
        }
    }

    open var content: Content = .initial {
        didSet { updateContent() }
    }
    
    fileprivate var isInitialized: Bool = false

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !isInitialized, superview != nil else { return }

        isInitialized = true

        setUpLayout()
        setUpAppearance()
        updateContent()
        setupSlider()
    }

    // MARK: - UI Components

    open lazy var audioVisualizationView: AudioVisualizationView = .init()
        .withoutAutoresizingMaskConstraints

    open lazy var slider: UISlider = .init()
        .withoutAutoresizingMaskConstraints

    // MARK: - UI Lifecycle

    open func setUpLayout() {
        setNeedsLayout()
        embed(audioVisualizationView, insets: .zero)
        embed(slider, insets: .zero)
    }

    open func setUpAppearance() {
        setNeedsLayout()
        audioVisualizationView.backgroundColor = .clear

        applySliderThumb(isPlaying: false)
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
    }

    open func updateContent() {
        slider.isUserInteractionEnabled = !content.isRecording
        slider.isHidden = content.isRecording
        slider.maximumValue = Float(content.duration)
        slider.minimumValue = 0
        slider.value = Float(content.currentTime)

        applySliderThumb(isPlaying: content.isPlaying)

        audioVisualizationView.audioVisualizationMode = content.isRecording ? .write : .read
        if audioVisualizationView.content != content.waveform {
            audioVisualizationView.content = content.waveform
        }
        audioVisualizationView.currentGradientPercentage = content.duration > 0
            ? max(0, min(1, Float(content.currentTime / content.duration)))
            : 0
        audioVisualizationView.setNeedsLayout()
        audioVisualizationView.setNeedsDisplay()
    }
    
    // MARK: - Slider
    
    private func setupSlider() {
        slider.addTarget(
            self,
            action: #selector(didSlide),
            for: .valueChanged
        )

        slider.addTarget(
            self,
            action: #selector(didTouchUpSlider),
            for: .touchUpInside
        )
    }
    
    @objc func didSlide(
        _ sender: UISlider
    ) {
        let value = TimeInterval(sender.value)
        onSliderChanged?(value)
    }

    @objc func didTouchUpSlider(
        _ sender: UISlider
    ) {
        onSliderTapped?()
    }

    // MARK: - Slider Thumb

    private static var cachedActiveThumb: UIImage?
    private static var cachedInactiveThumb: UIImage?

    private static func makeSliderThumbImage(
        fillColor: UIColor,
        borderColor: UIColor
    ) -> UIImage {
        let diameter: CGFloat = 12
        let borderWidth: CGFloat = 1
        let shadowBlur: CGFloat = 6
        let shadowOffsetY: CGFloat = 2
        let canvasSize = CGSize(
            width: diameter + shadowBlur * 2,
            height: diameter + shadowBlur * 2 + shadowOffsetY
        )
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { ctx in
            let cgContext = ctx.cgContext
            let thumbRect = CGRect(
                x: (canvasSize.width - diameter) / 2,
                y: (canvasSize.height - diameter - shadowOffsetY) / 2,
                width: diameter,
                height: diameter
            )
            let path = UIBezierPath(ovalIn: thumbRect)

            cgContext.setShadow(
                offset: CGSize(width: 0, height: shadowOffsetY),
                blur: shadowBlur,
                color: UIColor.black.withAlphaComponent(0.14).cgColor
            )
            fillColor.setFill()
            path.fill()

            cgContext.setShadow(offset: .zero, blur: 0, color: nil)
            borderColor.setStroke()
            path.lineWidth = borderWidth
            path.stroke()
        }
    }

    func applySliderThumb(isPlaying: Bool) {
        let colors = InjectedValues[\.colors]
        let thumb: UIImage
        if isPlaying {
            if let cached = Self.cachedActiveThumb {
                thumb = cached
            } else {
                thumb = Self.makeSliderThumbImage(
                    fillColor: colors.controlPlaybackThumbBackgroundActive,
                    borderColor: colors.controlPlaybackThumbBorderActive
                )
                Self.cachedActiveThumb = thumb
            }
        } else {
            if let cached = Self.cachedInactiveThumb {
                thumb = cached
            } else {
                thumb = Self.makeSliderThumbImage(
                    fillColor: colors.controlPlaybackThumbBackgroundDefault,
                    borderColor: colors.controlPlaybackThumbBorderDefault
                )
                Self.cachedInactiveThumb = thumb
            }
        }
        slider.setThumbImage(thumb, for: .normal)
        slider.setThumbImage(thumb, for: .highlighted)
    }
}

/// SwiftUI wrapper used during active recording (locked/stopped states in the composer).
/// Passes raw waveform data directly rather than an `AddedVoiceRecording`.
struct RecordingWaveform: UIViewRepresentable {
    var isRecording: Bool
    var isPlaying: Bool = false
    var duration: TimeInterval
    var currentTime: TimeInterval
    var waveform: [Float]
    var onSliderChanged: (TimeInterval) -> Void = { _ in }
    var onSliderTapped: () -> Void = {}
    
    func makeUIView(context: Context) -> WaveformView {
        let view = WaveformView()
        view.onSliderChanged = onSliderChanged
        view.onSliderTapped = onSliderTapped
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
            isPlaying: isPlaying,
            duration: duration,
            currentTime: currentTime,
            waveform: waveform
        )
        view.slider.isUserInteractionEnabled = !isRecording
    }
}

/// SwiftUI wrapper used for completed voice recordings (message list, composer attachments).
/// Reads playback state from an `AddedVoiceRecording` and optional `AudioPlaybackContext`.
struct WaveformViewSwiftUI: UIViewRepresentable {
    var audioContext: AudioPlaybackContext?
    var addedVoiceRecording: AddedVoiceRecording
    var isPlaying: Bool = false
    var onSliderChanged: (TimeInterval) -> Void
    var onSliderTapped: () -> Void
    
    func makeUIView(context: Context) -> WaveformView {
        let view = WaveformView()
        view.onSliderTapped = onSliderTapped
        view.onSliderChanged = onSliderChanged
        updateContent(for: view)
        return view
    }
    
    func updateUIView(_ uiView: WaveformView, context: Context) {
        uiView.onSliderChanged = onSliderChanged
        uiView.onSliderTapped = onSliderTapped
        updateContent(for: uiView)
    }
    
    private func updateContent(for view: WaveformView) {
        if let audioContext, addedVoiceRecording.url == audioContext.assetLocation {
            view.content = .init(
                isRecording: false,
                isPlaying: isPlaying,
                duration: audioContext.duration,
                currentTime: audioContext.currentTime,
                waveform: addedVoiceRecording.waveform
            )
        } else {
            view.content = .init(
                isRecording: false,
                duration: addedVoiceRecording.duration,
                currentTime: 0,
                waveform: addedVoiceRecording.waveform
            )
        }
    }
}
