//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Helper for creating snapshot from SwiftUI Views.
public protocol SnapshotCreator {
    
    /// Creates a snapshot of the provided SwiftUI view.
    ///  - Parameter view: the view whose snapshot would be created.
    ///  - Returns: `UIImage` representing the snapshot of the view.
    func makeSnapshot(for view: AnyView) -> UIImage
}

/// Default implementation of the `SnapshotCreator`.
public class DefaultSnapshotCreator: SnapshotCreator {
    
    @Injected(\.images) var images
    
    public init() { /* Public init. */ }
    
    public func makeSnapshot(for view: AnyView) -> UIImage {
        let currentSnapshot: UIImage?
        guard let view: UIView = topVC()?.view else {
            return images.snapshot
        }
        UIGraphicsBeginImageContext(view.frame.size)
        if let currentGraphicsContext = UIGraphicsGetCurrentContext() {
            view.layer.render(in: currentGraphicsContext)
            currentSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        } else {
            currentSnapshot = images.snapshot
        }
        UIGraphicsEndImageContext()
        return currentSnapshot ?? images.snapshot
    }
}
