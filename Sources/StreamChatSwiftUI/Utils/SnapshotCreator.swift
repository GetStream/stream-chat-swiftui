//
// Copyright © 2024 Stream.io Inc. All rights reserved.
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
        guard let uiView: UIView = topVC()?.view else {
            return images.snapshot
        }
        return makeSnapshot(from: uiView)
    }

    func makeSnapshot(from view: UIView) -> UIImage {
        let currentSnapshot: UIImage?
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
