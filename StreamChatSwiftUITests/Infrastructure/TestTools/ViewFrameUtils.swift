//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    func applyDefaultSize() -> some View {
        frame(
            width: defaultScreenSize.width,
            height: defaultScreenSize.height
        )
    }
    
    func applySize(_ size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }

    @discardableResult
    /// Add SwiftUI View to a fake hierarchy so that it can receive UI events.
    func addToViewHierarchy() -> some View {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let hostingController = UIHostingController(rootView: self)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.layoutIfNeeded()
        return self
    }
}
