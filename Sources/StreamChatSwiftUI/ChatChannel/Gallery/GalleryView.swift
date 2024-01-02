//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for displaying image attachments in a gallery.
public struct GalleryView: View {

    @Environment(\.presentationMode) var presentationMode

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    var imageAttachments: [ChatMessageImageAttachment]
    var author: ChatUser
    @Binding var isShown: Bool
    @State private var selected: Int
    @State private var loadedImages = [Int: UIImage]()
    @State private var gridShown = false

    public init(
        imageAttachments: [ChatMessageImageAttachment],
        author: ChatUser,
        isShown: Binding<Bool>,
        selected: Int
    ) {
        self.imageAttachments = imageAttachments
        self.author = author
        _isShown = isShown
        _selected = State(initialValue: selected)
    }

    public var body: some View {
        GeometryReader { reader in
            VStack {
                GalleryHeaderView(
                    title: author.name ?? "",
                    subtitle: author.onlineText,
                    isShown: $isShown
                )

                TabView(selection: $selected) {
                    ForEach(0..<sources.count, id: \.self) { index in
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
                                .aspectRatio(contentMode: .fit)
                                .frame(width: reader.size.width)
                                Spacer()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color(colors.background1))
                .gesture(
                    DragGesture().onEnded { value in
                        if value.location.y - value.startLocation.y > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )

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
        imageAttachments.map { attachment in
            attachment.imageURL
        }
    }
}
