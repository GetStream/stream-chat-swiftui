//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import UIKit
@testable import StreamChat
import StreamChatSwiftUI

class ImageLoader_Mock: ImageLoading {
    
    static let defaultLoadedImage = UIImage(systemName: "checkmark")!
    
    func loadImage(
        url: URL?,
        imageCDN: ImageCDN,
        resize: Bool,
        preferredSize: CGSize?,
        completion: @escaping ((Result<UIImage, Error>) -> Void)) {
            completion(.success(Self.defaultLoadedImage))
    }
    
}
