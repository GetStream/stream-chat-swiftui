//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import Foundation

/// Loads the duration of an audio or video asset, for payloads that don't provide one.
enum AssetDurationLoader: Sendable {
    static func duration(from url: URL) async -> TimeInterval? {
        let asset = AVURLAsset(url: url)
        if #available(iOS 16, *) {
            guard let duration = try? await asset.load(.duration) else { return nil }
            return validDuration(duration.seconds)
        } else {
            return await withCheckedContinuation { continuation in
                asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                    var error: NSError?
                    let status = asset.statusOfValue(forKey: "duration", error: &error)
                    guard status == .loaded else {
                        continuation.resume(returning: nil)
                        return
                    }
                    continuation.resume(returning: validDuration(asset.duration.seconds))
                }
            }
        }
    }

    private static func validDuration(_ seconds: TimeInterval) -> TimeInterval? {
        seconds.isFinite && seconds > 0 ? seconds : nil
    }
}
