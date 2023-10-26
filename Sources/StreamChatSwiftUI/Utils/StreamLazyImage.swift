//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct StreamLazyImage: View {
        
    var url: URL?
    var size: CGSize
    
    public init(url: URL?, size: CGSize = CGSize(width: 30, height: 30)) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        LazyImage(url: url)
            .onDisappear(.cancel)
            .clipShape(Circle())
            .frame(
                width: size.width,
                height: size.height
            )
    }
}
