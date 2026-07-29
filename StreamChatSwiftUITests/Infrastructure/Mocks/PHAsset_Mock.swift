//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos

final class PHAsset_Mock: PHAsset, @unchecked Sendable {
    private let mockId: String
    private let mockMediaType: PHAssetMediaType
    private let mockDuration: TimeInterval
    private let mockPixelWidth: Int
    private let mockPixelHeight: Int

    init(
        id: String = UUID().uuidString,
        mediaType: PHAssetMediaType = .image,
        duration: TimeInterval = 0,
        pixelWidth: Int = 100,
        pixelHeight: Int = 100
    ) {
        mockId = id
        mockMediaType = mediaType
        mockDuration = duration
        mockPixelWidth = pixelWidth
        mockPixelHeight = pixelHeight
        super.init()
    }

    override var localIdentifier: String { mockId }
    override var mediaType: PHAssetMediaType { mockMediaType }
    override var duration: TimeInterval { mockDuration }
    override var pixelWidth: Int { mockPixelWidth }
    override var pixelHeight: Int { mockPixelHeight }
}
