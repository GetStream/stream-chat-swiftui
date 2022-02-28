//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Nuke
import SwiftyGif
import UIKit

internal extension EmojiRendering {
    var gifLevelOfIntegrity: GifLevelOfIntegrity {
        switch quality {
        case .highest: return .highestNoFrameSkipping
        case .high: return .default
        case .medium: return .lowForManyGifs
        case .low: return .lowForTooManyGifs
        case .lowest: return .superLowForSlideShow
        }
    }
}

internal extension UIImageView {
    func setFromURL(_ url: URL, rendering: EmojiRendering) {
        Nuke.ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
        Nuke.ImagePipeline.shared.loadImage(with: url) { result in
            switch result {
            case let .success(response):
                if let animation = response.image.animatedImageData,
                   let gifImage = try? UIImage(gifData: animation, levelOfIntegrity: rendering.gifLevelOfIntegrity) {
                    DispatchQueue.main.async {
                        self.setGifImage(gifImage)
                        self.startAnimating()
                    }
                } else if let image = response.image.cgImage {
                    DispatchQueue.main.async {
                        self.setImage(.init(cgImage: image))
                    }
                }
            case .failure:
                break
            }
        }
    }
    
    func setFromAsset(_ name: String, rendering: EmojiRendering) {
        DispatchQueue.main.async {
            if let asset = NSDataAsset(name: name),
               let gifImage = try? UIImage(gifData: asset.data, levelOfIntegrity: rendering.gifLevelOfIntegrity) {
                self.setGifImage(gifImage)
                self.startAnimating()
            } else if let image = UIImage(named: name) {
                self.setImage(image)
            }
        }
    }
}

internal final class EmojiView: UIView {
    private let imageView: UIImageView = UIImageView()
    internal let label: UILabel = UILabel()

    private var token: NSKeyValueObservation?
    internal func setFromRenderView(_ view: UIImageView) {
        imageView.image = view.image
        token = view.observe(\.image) { [weak self] _, _ in
            self?.imageView.image = view.image
        }
    }

    override internal init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        imageView.contentMode = .scaleAspectFit
        label.font = .systemFont(ofSize: frame.width / 1.1)
        label.numberOfLines = 0
        addSubview(imageView)
        addSubview(label)
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        imageView.frame = bounds
    }
}
