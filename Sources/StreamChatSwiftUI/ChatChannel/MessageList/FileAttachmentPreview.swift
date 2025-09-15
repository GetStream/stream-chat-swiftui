//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View previewing file attachments.
public struct FileAttachmentPreview: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils

    private var fileCDN: FileCDN {
        utils.fileCDN
    }

    let title: String?
    var url: URL

    @State private var adjustedUrl: URL?
    @State private var isLoading = false
    @State private var webViewTitle: String?
    @State private var error: Error?
    
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
                    if let adjustedUrl = adjustedUrl {
                        WebView(
                            url: adjustedUrl,
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
                fileCDN.adjustedURL(for: url) { result in
                    switch result {
                    case let .success(url):
                        self.adjustedUrl = url
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
            }
        }
    }
}
