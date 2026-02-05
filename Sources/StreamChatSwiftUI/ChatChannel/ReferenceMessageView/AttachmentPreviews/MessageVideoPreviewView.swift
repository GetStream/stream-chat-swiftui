//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Video attachment preview for messages.
public struct MessageVideoPreviewView: View {
    @Injected(\.tokens) private var tokens

    private let thumbnailURL: URL
    private let size: CGFloat

    /// Creates a video attachment preview with the given thumbnail URL.
    /// - Parameters:
    ///   - thumbnailURL: The URL of the video thumbnail to preview.
    ///   - size: The size of the preview (width and height). Defaults to 40.
    public init(thumbnailURL: URL, size: CGFloat = 40) {
        self.thumbnailURL = thumbnailURL
        self.size = size
    }

    public var body: some View {
        MessageImagePreviewView(url: thumbnailURL, size: size)
            .overlay(PlayButtonOverlay())
    }
}

// MARK: - Deprecated Typealiases

/// Deprecated: Use `MessageVideoPreviewView` instead.
@available(*, deprecated, renamed: "MessageVideoPreviewView")
public typealias QuotedMessageVideoPreviewView = MessageVideoPreviewView
