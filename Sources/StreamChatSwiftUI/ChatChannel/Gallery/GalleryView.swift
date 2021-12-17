//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct GalleryView: View {

    @Injected(\.colors) private var colors
    
    var message: ChatMessage
    @Binding var isShown: Bool
    @State private var selected: Int
    @State private var loadedImages = [Int: UIImage]()
    
    init(
        message: ChatMessage,
        isShown: Binding<Bool>,
        selected: Int
    ) {
        self.message = message
        _isShown = isShown
        _selected = State(initialValue: selected)
    }
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                GalleryHeaderView(
                    title: message.author.name ?? "",
                    subtitle: message.author.onlineText,
                    isShown: $isShown
                )

                TabView(selection: $selected) {
                    ForEach(0..<sources.count) { index in
                        let url = sources[index]
                        ZoomableScrollView {
                            VStack {
                                Spacer()
                                LazyLoadingImage(
                                    source: url,
                                    width: reader.size.width,
                                    resize: true,
                                    onImageLoaded: { image in
                                        loadedImages[index] = image
                                    }
                                )
                                .frame(width: reader.size.width)
                                .aspectRatio(contentMode: .fit)
                                Spacer()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                if let image = loadedImages[selected] {
                    HStack {
                        ShareButtonView(content: [image])
                            .standardPadding()
                        
                        Spacer()
                        
                        Text("\(selected + 1) of \(sources.count)")
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var sources: [URL] {
        message.imageAttachments.map { attachment in
            attachment.imageURL
        }
    }
}
