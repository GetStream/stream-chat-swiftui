//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

public struct FileAttachmentsContainer: View {
    var message: ChatMessage
    var width: CGFloat
    var isFirst: Bool
    
    public var body: some View {
        VStack(spacing: 4) {
            ForEach(message.fileAttachments, id: \.self) { attachment in
                if message.text.isEmpty {
                    FileAttachmentView(
                        attachment: attachment,
                        width: width,
                        isFirst: isFirst
                    )
                } else {
                    VStack(spacing: 0) {
                        FileAttachmentView(
                            attachment: attachment,
                            width: width,
                            isFirst: isFirst
                        )

                        HStack {
                            Text(message.text)
                                .standardPadding()
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.all, 4)
        .messageBubble(for: message, isFirst: isFirst)
    }
}

public struct FileAttachmentView: View {
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    @State private var fullScreenShown = false
    
    var attachment: ChatMessageFileAttachment
    var width: CGFloat
    var isFirst: Bool
    
    public var body: some View {
        HStack {
            FileAttachmentDisplayView(
                url: attachment.assetURL,
                title: attachment.title ?? "",
                sizeString: attachment.file.sizeString
            )
            .onTapGesture {
                fullScreenShown = true
            }
            
            Spacer()
        }
        .padding(.all, 8)
        .background(Color(colors.background))
        .frame(width: width)
        .roundWithBorder()
        .withUploadingStateIndicator(for: attachment.uploadingState, url: attachment.assetURL)
        .sheet(isPresented: $fullScreenShown) {
            FileAttachmentPreview(url: attachment.assetURL)
        }
    }
}

struct FileAttachmentDisplayView: View {
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var url: URL
    var title: String
    var sizeString: String
    
    var body: some View {
        HStack {
            Image(uiImage: previewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 40)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(fonts.bodyBold)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.text))
                Text(sizeString)
                    .font(fonts.footnote)
                    .lineLimit(1)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            Spacer()
        }
    }
    
    private var previewImage: UIImage {
        let iconName = url.pathExtension
        return images.documentPreviews[iconName] ?? images.fileFallback
    }
}
