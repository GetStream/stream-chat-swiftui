//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine

extension Publisher where Failure == Never {
    /// Assigns each element from a publisher to a property on an object without retaining the object.
    func assignWeakly<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        on root: Root
    ) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
}
