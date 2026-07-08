//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View previewing file attachments.
public struct FileAttachmentPreview: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils

    let attachment: ChatMessageFileAttachment
    
    @State private var fileRequest: URLRequest?
    @State private var isLoading = false
    @State private var webViewTitle: String?
    @State private var error: Error?
    @State private var sharedFile: ShareSheet.SharedFile?

    var title: String? {
        attachment.title
    }
    
    var url: URL {
        if attachment.downloadingState?.state == .downloaded,
           let url = attachment.downloadingState?.localFileURL,
           FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return attachment.assetURL
    }
    
    var navigationTitle: String {
        if let title, !title.isEmpty { return title }
        if let webViewTitle, !webViewTitle.isEmpty { return webViewTitle }
        return url.absoluteString
    }
    
    public var body: some View {
        NavigationContainerView(embedInNavigationView: true) {
            ZStack {
                if error != nil {
                    Text(L10n.Message.FileAttachment.errorPreview)
                        .font(fonts.body)
                        .padding()
                } else {
                    if let fileRequest {
                        WebView(
                            request: fileRequest,
                            isLoading: $isLoading,
                            title: $webViewTitle,
                            error: $error
                        )
                    }

                    if isLoading {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                if url.isFileURL {
                    fileRequest = URLRequest(url: url)
                    return
                }
                utils.mediaLoader.loadFileRequest(for: url) { result in
                    switch result {
                    case let .success(result):
                        fileRequest = result.urlRequest
                    case let .failure(error):
                        self.error = error
                    }
                }
            }
            .sheet(item: $sharedFile) { sharedFile in
                ShareSheet(files: [sharedFile])
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarThemed {
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.navigationBarTitle))
                        .lineLimit(1)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(uiImage: images.close)
                            .renderingMode(.template)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    DownloadShareAttachmentView(attachment: attachment) { fileURL in
                        sharedFile = ShareSheet.SharedFile(url: fileURL)
                    }
                }
            }
        }
    }
}
