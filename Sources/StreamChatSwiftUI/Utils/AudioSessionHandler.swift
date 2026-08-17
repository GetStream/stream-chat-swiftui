//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

class AudioSessionHandler: ObservableObject, AudioPlayingDelegate {
    @Injected(\.utils) private var utils

    @Published var context: AudioPlaybackContext = .notLoaded
    @Published var isPlaying: Bool = false
    @Published var rate: AudioPlaybackRate = .normal

    private var player: AudioPlaying { utils.audioPlayer }

    func audioPlayer(
        _ audioPlayer: AudioPlaying,
        didUpdateContext context: AudioPlaybackContext
    ) {
        self.context = context
    }

    var rateTitle: String {
        switch rate {
        case .half: "x0.5"
        default: "x\(Int(rate.rawValue))"
        }
    }

    func updatePlaybackState(for url: URL) {
        guard context.assetLocation == url else { return }
        switch context.state {
        case .playing:
            if !isPlaying {
                isPlaying = true
                player.updateRate(rate)
            }
        case .stopped, .paused:
            isPlaying = false
        default:
            break
        }
    }

    func togglePlayback(for url: URL) {
        if isPlaying {
            player.pause()
        } else {
            player.loadAsset(from: url)
        }
    }

    func cycleRate() {
        switch rate {
        case .normal: rate = .double
        case .double: rate = .half
        default: rate = .normal
        }
        if isPlaying {
            player.updateRate(rate)
        }
    }

    func isActive(for url: URL) -> Bool {
        context.assetLocation == url
    }

    /// Returns remaining playback time when playing/paused, or the total duration otherwise.
    func displayedTime(for url: URL, duration: TimeInterval) -> TimeInterval {
        guard isActive(for: url) else { return duration }
        switch context.state {
        case .playing, .paused:
            let resolvedDuration = max(duration, context.duration)
            return max(resolvedDuration - context.currentTime, 0)
        default:
            return duration
        }
    }

    func seek(to time: TimeInterval, loadingFrom url: URL? = nil) {
        if let url, !isActive(for: url) {
            player.loadAsset(from: url)
        }
        player.seek(to: time)
    }
}
