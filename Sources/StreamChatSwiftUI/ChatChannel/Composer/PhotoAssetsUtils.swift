//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Photos
import SwiftUI

/// Helper class that loads assets from the photo library.
public class PhotoAssetLoader: NSObject, ObservableObject {
    @Published var loadedImages = [String: UIImage]()
    
    /// Loads an image from the provided asset.
    func loadImage(from asset: PHAsset) {
        if loadedImages[asset.localIdentifier] != nil {
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .opportunistic
        
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
    
    /// Clears the cache when there's memory warning.
    func didReceiveMemoryWarning() {
        loadedImages = [String: UIImage]()
    }
}

extension PHAsset {
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

    public subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }
}
