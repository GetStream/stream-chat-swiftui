//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation

/// Represents a thumbnail for an attachment preview in a message reference.
public struct MessageAttachmentPreviewThumbnail {
    /// The type of thumbnail.
    public let type: String
    
    /// The URL for the thumbnail (used for image and video types).
    public let url: URL?
    
    private init(type: String, url: URL?) {
        self.type = type
        self.url = url
    }
    
    // MARK: - Static Initializers
    
    /// Creates an image thumbnail with the given URL.
    /// - Parameter url: The URL of the image.
    /// - Returns: An image thumbnail.
    public static func image(url: URL) -> Self {
        .init(type: "image", url: url)
    }
    
    /// Creates a video thumbnail with the given URL.
    /// - Parameter url: The URL of the video thumbnail.
    /// - Returns: A video thumbnail.
    public static func video(url: URL) -> Self {
        .init(type: "video", url: url)
    }
    
    /// Creates a file thumbnail with the given URL.
    /// The file extension is extracted from the URL.
    /// - Parameter url: The URL of the file.
    /// - Returns: A file thumbnail.
    public static func file(url: URL) -> Self {
        .init(type: "file", url: url)
    }
    
    // MARK: - Computed Properties

    /// Whether this is an image thumbnail.
    public var isImage: Bool {
        type == "image"
    }
    
    /// Whether this is a video thumbnail.
    public var isVideo: Bool {
        type == "video"
    }
    
    /// Whether this is a file thumbnail.
    public var isFile: Bool {
        type == "file"
    }
}
