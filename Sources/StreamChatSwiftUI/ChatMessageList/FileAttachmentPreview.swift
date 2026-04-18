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
    
    var title: String? {
        attachment.title
    }
    
    var url: URL {
        attachment.assetURL
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
                utils.mediaLoader.loadFileRequest(for: url) { result in
                    switch result {
                    case let .success(result):
                        fileRequest = result.urlRequest
                    case let .failure(error):
                        self.error = error
                    }
                }
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
                    DownloadShareAttachmentView(attachment: attachment)
                }
            }
        }
    }
}
