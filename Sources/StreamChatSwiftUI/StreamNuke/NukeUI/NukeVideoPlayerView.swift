// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import AVKit
import Foundation

#if !os(watchOS)

@MainActor
final class NukeVideoPlayerView: _PlatformBaseView {
    // MARK: Configuration

    /// `.resizeAspectFill` by default.
    var videoGravity: AVLayerVideoGravity = .resizeAspectFill {
        didSet {
            _playerLayer?.videoGravity = videoGravity
        }
    }

    /// `true` by default. If disabled, will only play a video once.
    var isLooping = true {
        didSet {
            guard isLooping != oldValue else { return }
            player?.actionAtItemEnd = isLooping ? .none : .pause
            if isLooping, !(player?.nowPlaying ?? false) {
                restart()
            }
        }
    }

    /// Add if you want to do something at the end of the video
    var onVideoFinished: (() -> Void)?

    // MARK: Initialization

    var playerLayer: AVPlayerLayer {
        if let layer = _playerLayer {
            return layer
        }
        let playerLayer = AVPlayerLayer()
#if os(macOS)
        wantsLayer = true
        self.layer?.addSublayer(playerLayer)
#else
        self.layer.addSublayer(playerLayer)
#endif
        playerLayer.frame = bounds
        playerLayer.videoGravity = videoGravity
        _playerLayer = playerLayer
        return playerLayer
    }

    private var _playerLayer: AVPlayerLayer?

    #if os(iOS) || os(tvOS)
    override func layoutSubviews() {
        super.layoutSubviews()

        _playerLayer?.frame = bounds
    }
    #elseif os(macOS)
    override func layout() {
        super.layout()

        _playerLayer?.frame = bounds
    }
#endif

    // MARK: Private

    private var player: AVPlayer? {
        didSet {
            registerNotifications()
        }
    }

    private var playerObserver: AnyObject?

    func reset() {
        _playerLayer?.player = nil
        player = nil
        playerObserver = nil
    }

    var asset: AVAsset? {
        didSet { assetDidChange() }
    }

    private func assetDidChange() {
        if asset == nil {
            reset()
        }
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTimeNotification(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

#if os(iOS) || os(tvOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
#endif
    }

    func restart() {
        player?.seek(to: CMTime.zero)
        player?.play()
    }

    func play() {
        guard let asset = asset else {
            return
        }

        let playerItem = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: playerItem)
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        player.actionAtItemEnd = isLooping ? .none : .pause
        self.player = player

        playerLayer.player = player

        playerObserver = player.observe(\.status, options: [.new, .initial]) { player, _ in
            Task { @MainActor in
                if player.status == .readyToPlay {
                    player.play()
                }
            }
        }
    }

    @objc private func playerItemDidPlayToEndTimeNotification(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else {
            return
        }
        if isLooping {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        } else {
            onVideoFinished?()
        }
    }

    @objc private func applicationWillEnterForeground() {
        if shouldResumeOnInterruption {
            player?.play()
        }
    }

#if os(iOS) || os(tvOS)
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil && shouldResumeOnInterruption {
            player?.play()
        }
    }
#endif

    private var shouldResumeOnInterruption: Bool {
        return player?.nowPlaying == false &&
        player?.status == .readyToPlay &&
        isLooping
    }
}

extension AVLayerVideoGravity {
    init(_ contentMode: ImageResizingMode) {
        switch contentMode {
        case .fill: self = .resize
        case .aspectFill: self = .resizeAspectFill
        default: self = .resizeAspect
        }
    }
}

@MainActor
extension AVPlayer {
    var nowPlaying: Bool {
        rate != 0 && error == nil
    }
}

#endif
