//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Photos

final class PHFetchResult_Mock: PHFetchResult<PHAsset>, @unchecked Sendable {
    private let mockAssets: [PHAsset]

    init(assets: [PHAsset]) {
        mockAssets = assets
        super.init()
    }

    override var count: Int { mockAssets.count }
    override var firstObject: PHAsset? { mockAssets.first }
    override var lastObject: PHAsset? { mockAssets.last }

    override func object(at index: Int) -> PHAsset {
        mockAssets[index]
    }
}
