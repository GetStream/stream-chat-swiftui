//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI
import AVKit

/// View used for displaying image attachments in a gallery.
public struct GalleryView: View {

    @Environment(\.presentationMode) var presentationMode

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    var mediaAttachments: [MediaAttachment]
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
        let mediaAttachments = imageAttachments.map { attachment in
            let url: URL
            if let state = attachment.uploadingState {
                url = state.localFileURL
            } else {
                url = attachment.imageURL
            }
            return MediaAttachment(
                url: url,
                type: .image,
                uploadingState: attachment.uploadingState
            )
        }
        self.init(
            mediaAttachments: mediaAttachments,
            author: author,
            isShown: isShown,
            selected: selected
        )
    }
    
    init(
        mediaAttachments: [MediaAttachment],
        author: ChatUser,
        isShown: Binding<Bool>,
        selected: Int
    ) {
        self.mediaAttachments = mediaAttachments
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
                    ForEach(0..<mediaAttachments.count, id: \.self) { index in
                        ZStack {
                            let source = mediaAttachments[index]
                            if source.type == .image {
                                ZoomableScrollView {
                                    VStack {
                                        Spacer()
                                        LazyLoadingImage(
                                            source: source,
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
                            } else {
                                StreamVideoPlayer(url: source.url)
                                    .tag(index)
                            }
                        }
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

                    Text("\(selected + 1) of \(mediaAttachments.count)")
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
                    imageURLs: mediaAttachments.filter { $0.type == .image }.map(\.url),
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
}

struct StreamVideoPlayer: View {
    
    @State var player: AVPlayer
    
    init(url: URL) {
        let player = AVPlayer(url: url)
        _player = State(wrappedValue: player)
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                player.play()
            }
    }
}
