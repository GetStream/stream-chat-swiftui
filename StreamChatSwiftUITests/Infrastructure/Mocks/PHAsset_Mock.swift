//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import AVFoundation
import Photos

final class PHAsset_Mock: PHAsset, @unchecked Sendable {
    /// Options of every `requestContentEditingInput` call, in order.
    var contentEditingInputRequests = [PHContentEditingInputRequestOptions]()
    var cancelledContentEditingInputRequestIds = [PHContentEditingInputRequestID]()

    /// Handed to the completion of `requestContentEditingInput`. When nil, the completion is never called.
    var contentEditingInput: PHContentEditingInput?
    var contentEditingInputRequestId: PHContentEditingInputRequestID = 1

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

    override func requestContentEditingInput(
        with options: PHContentEditingInputRequestOptions?,
        completionHandler: @escaping (PHContentEditingInput?, [AnyHashable: Any]) -> Void
    ) -> PHContentEditingInputRequestID {
        contentEditingInputRequests.append(options ?? PHContentEditingInputRequestOptions())
        if let contentEditingInput {
            completionHandler(contentEditingInput, [:])
        }
        return contentEditingInputRequestId
    }

    override func cancelContentEditingInputRequest(_ requestID: PHContentEditingInputRequestID) {
        cancelledContentEditingInputRequestIds.append(requestID)
    }
}

final class PHContentEditingInput_Mock: PHContentEditingInput, @unchecked Sendable {
    private let mockFullSizeImageURL: URL?
    private let mockAudiovisualAsset: AVAsset?

    init(fullSizeImageURL: URL? = nil, audiovisualAsset: AVAsset? = nil) {
        mockFullSizeImageURL = fullSizeImageURL
        mockAudiovisualAsset = audiovisualAsset
        super.init()
    }

    override var fullSizeImageURL: URL? { mockFullSizeImageURL }
    override var audiovisualAsset: AVAsset? { mockAudiovisualAsset }
}
