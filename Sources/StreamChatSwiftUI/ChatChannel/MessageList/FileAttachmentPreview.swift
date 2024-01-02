//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View previewing file attachments.
public struct FileAttachmentPreview: View {
    @Environment(\.presentationMode) var presentationMode

    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images

    var url: URL

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
                    WebView(
                        url: url,
                        isLoading: $isLoading,
                        title: $title,
                        error: $error
                    )

                    if isLoading {
                        ProgressView()
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
