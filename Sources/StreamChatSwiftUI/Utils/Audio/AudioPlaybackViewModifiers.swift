//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

extension View {
    /// Subscribes the handler to the audio player and plays the next asset when the current one finishes.
    func audioPlaybackQueue(handler: AudioSessionHandler, urls: [URL]) -> some View {
        modifier(AudioPlaybackQueueModifier(handler: handler, urls: urls))
    }

    /// Keeps the handler's playback state in sync with the player context for the given asset.
    func audioPlaybackStateUpdates(handler: AudioSessionHandler, url: URL) -> some View {
        onReceive(handler.$context) { context in
            guard context.assetLocation == url, context.state != .loading else { return }
            handler.updatePlaybackState(for: url)
        }
    }
}

private struct AudioPlaybackQueueModifier: ViewModifier {
    @Injected(\.utils) private var utils

    let handler: AudioSessionHandler
    let urls: [URL]

    @State private var playingIndex: Int?

    func body(content: Content) -> some View {
        content
            .onReceive(handler.$context) { _ in
                playingIndex = handler.advanceQueueIfNeeded(urls: urls, playingIndex: playingIndex)
            }
            .onAppear {
                utils.audioPlayer.subscribe(handler)
            }
    }
}
