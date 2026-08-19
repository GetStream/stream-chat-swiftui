//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import Foundation

extension AVURLAsset {
    /// Loads the asset duration when it is not available from the attachment payload.
    func loadDuration() async -> TimeInterval? {
        if #available(iOS 16, *) {
            guard let duration = try? await load(.duration) else { return nil }
            return Self.validDuration(duration.seconds)
        }

        return await withCheckedContinuation { continuation in
            loadValuesAsynchronously(forKeys: ["duration"]) { [self] in
                var error: NSError?
                let status = self.statusOfValue(forKey: "duration", error: &error)
                guard status == .loaded else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: Self.validDuration(self.duration.seconds))
            }
        }
    }

    private static func validDuration(_ seconds: TimeInterval) -> TimeInterval? {
        seconds.isFinite && seconds > 0 ? seconds : nil
    }
}
