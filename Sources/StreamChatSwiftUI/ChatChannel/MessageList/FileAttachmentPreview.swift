//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View previewing file attachments.
public struct FileAttachmentPreview: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils

    private var fileCDN: FileCDN {
        utils.fileCDN
    }

    var url: URL

    @State private var adjustedUrl: URL?
    @State private var isLoading = false
    @State private var title: String?
    @State private var error: Error?

    public var body: some View {
        NavigationView {
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
                            title: $title,
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title ?? url.absoluteString)
                        .font(fonts.bodyBold)
                        .lineLimit(1)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(uiImage: images.close)
                    }
                }
            }
        }
    }
}
