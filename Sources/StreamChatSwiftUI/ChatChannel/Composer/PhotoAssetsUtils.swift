//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Photos
import StreamChat
import SwiftUI

/// Helper class that loads assets from the photo library.
public class PhotoAssetLoader: NSObject, ObservableObject {

    @Injected(\.chatClient) private var chatClient

    @Published var loadedImages = [String: UIImage]()

    /// Loads an image from the provided asset.
    func loadImage(from asset: PHAsset) {
        if loadedImages[asset.localIdentifier] != nil {
            return
        }

        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 250, height: 250),
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, _ in
            guard let self = self, let image = image else { return }
            self.loadedImages[asset.localIdentifier] = image
        }
    }

    func compressAsset(at url: URL, type: AssetType, completion: @escaping (URL?) -> Void) {
        if type == .video {
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
            compressVideo(inputURL: url, outputURL: compressedURL) { exportSession in
                guard let session = exportSession else {
                    return
                }

                switch session.status {
                case .completed:
                    completion(compressedURL)
                default:
                    completion(nil)
                }
            }
        }
    }

    func assetExceedsAllowedSize(url: URL?) -> Bool {
        _ = url?.startAccessingSecurityScopedResource()
        if let assetURL = url,
           let file = try? AttachmentFile(url: assetURL),
           file.size >= chatClient.config.maxAttachmentSize {
            return true
        } else {
            return false
        }
    }

    private func compressVideo(
        inputURL: URL,
        outputURL: URL,
        handler: @escaping (_ exportSession: AVAssetExportSession?) -> Void
    ) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)

        guard let exportSession = AVAssetExportSession(
            asset: urlAsset,
            presetName: AVAssetExportPresetMediumQuality
        ) else {
            handler(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }

    /// Clears the cache when there's memory warning.
    func didReceiveMemoryWarning() {
        loadedImages = [String: UIImage]()
    }
}

public extension PHAsset {
    /// Return a formatted duration string of an asset.
    var durationString: String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        var minutesString = "\(minutes)"
        var secondsString = "\(seconds)"
        if minutes < 10 {
            minutesString = "0" + minutesString
        }
        if seconds < 10 {
            secondsString = "0" + secondsString
        }

        return "\(minutesString):\(secondsString)"
    }
}

extension PHAsset: Identifiable {
    public var id: String {
        localIdentifier
    }
}

/// Helper collection that allows iteration over the fetched assets from the photo library.
public struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    public typealias Element = PHAsset
    public typealias Index = Int

    public let fetchResult: PHFetchResult<PHAsset>

    public var endIndex: Int { fetchResult.count }
    public var startIndex: Int { 0 }

    public init(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }

    public subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }
}
