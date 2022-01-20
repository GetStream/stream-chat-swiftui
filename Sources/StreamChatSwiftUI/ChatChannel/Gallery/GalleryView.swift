//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for displaying image attachments in a gallery.
struct GalleryView: View {

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    
    var message: ChatMessage
    @Binding var isShown: Bool
    @State private var selected: Int
    @State private var loadedImages = [Int: UIImage]()
    @State private var gridShown = false
    
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
                                    height: reader.size.height,
                                    resize: true,
                                    shouldSetFrame: false,
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
                .background(Color(colors.background1))
                
                HStack {
                    ShareButtonView(content: sharingContent)
                        .standardPadding()

                    Spacer()
                    
                    Text("\(selected + 1) of \(sources.count)")
                        .font(fonts.bodyBold)

                    Spacer()
                    
                    Button {
                        gridShown = true
                    } label: {
                        Image(uiImage: images.gallery)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16, alignment: .center)
                    }
                    .standardPadding()
                }
                .foregroundColor(Color(colors.text))
            }
            .sheet(isPresented: $gridShown) {
                GridPhotosView(
                    imageURLs: sources,
                    isShown: $gridShown
                )
            }
        }
    }
    
    private var sharingContent: [UIImage] {
        if let image = loadedImages[selected] {
            return [image]
        } else {
            return []
        }
    }
    
    private var sources: [URL] {
        message.imageAttachments.map { attachment in
            attachment.imageURL
        }
    }
}
