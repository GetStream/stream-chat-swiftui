//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI
import UIKit

/// Displays an interactive waveform visualisation of an audio file.
open class WaveformView: UIView {
    
    @Injected(\.images) var images
    
    var onSliderChanged: ((TimeInterval) -> Void)?
    var onSliderTapped: (() -> Void)?
    
    public struct Content: Equatable {
        /// When set to `true` the waveform will be updating with the data live (scrolling to the trailing side
        /// as new data arrive).
        public var isRecording: Bool

        /// The duration of the Audio file that we are representing.
        public var duration: TimeInterval

        /// The playback's currentTime for the Audio file we are representing.
        public var currentTime: TimeInterval

        /// The waveform's data that will be used to render the visualisation.
        public var waveform: [Float]

        public static let initial = Content(
            isRecording: false,
            duration: 0,
            currentTime: 0,
            waveform: []
        )

        public init(
            isRecording: Bool,
            duration: TimeInterval,
            currentTime: TimeInterval,
            waveform: [Float]
        ) {
            self.isRecording = isRecording
            self.duration = duration
            self.currentTime = currentTime
            self.waveform = waveform
        }
    }

    var content: Content = .initial {
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

    open private(set) lazy var audioVisualizationView: AudioVisualizationView = .init()
        .withoutAutoresizingMaskConstraints

    open private(set) lazy var slider: UISlider = .init()
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

        slider.setThumbImage(images.sliderThumb, for: .normal)
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
    }

    open func updateContent() {
        slider.isUserInteractionEnabled = !content.isRecording
        slider.isHidden = content.isRecording
        slider.maximumValue = Float(content.duration)
        slider.minimumValue = 0
        slider.value = Float(content.currentTime)

        audioVisualizationView.audioVisualizationMode = content.isRecording ? .write : .read
        if audioVisualizationView.content != content.waveform {
            audioVisualizationView.content = content.waveform
        }
        audioVisualizationView.currentGradientPercentage = max(0, min(1, Float(content.currentTime / content.duration)))
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
    
    @objc internal func didSlide(
        _ sender: UISlider
    ) {
        let value = TimeInterval(sender.value)
        onSliderChanged?(value)
    }

    @objc internal func didTouchUpSlider(
        _ sender: UISlider
    ) {
        onSliderTapped?()
    }
}

struct WaveformViewSwiftUI: UIViewRepresentable {
    var audioContext: AudioPlaybackContext?
    var addedVoiceRecording: AddedVoiceRecording
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
        updateContent(for: uiView)
    }
    
    private func updateContent(for view: WaveformView) {
        if let audioContext, addedVoiceRecording.url == audioContext.assetLocation {
            view.content = .init(
                isRecording: false,
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
