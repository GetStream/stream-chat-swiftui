//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct GridPhotosView: View {
    
    var loadedImages: [Int: UIImage]
    
    let columns = [GridItem(.adaptive(minimum: 120), spacing: 2)]
    
    private var sorted: [UIImage] {
        let keys = loadedImages.keys.sorted()
        return keys.compactMap { index in
            loadedImages[index]
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(sorted, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                }
            }
            .padding(.horizontal, 2)
            .animation(nil)
        }
    }
}
