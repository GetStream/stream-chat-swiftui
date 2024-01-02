//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import Network

/// Class that checks if the network is reachable.
class NetworkReachability {

    let pathMonitor: NWPathMonitor
    var path: NWPath?

    lazy var pathUpdateHandler: ((NWPath) -> Void) = { path in
        self.path = path
    }

    let backgroudQueue = DispatchQueue.global(qos: .background)

    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = pathUpdateHandler
        pathMonitor.start(queue: backgroudQueue)
    }

    func isNetworkAvailable() -> Bool {
        if let path = self.path {
            if path.status == NWPath.Status.satisfied {
                return true
            }
        }
        return false
    }
}
