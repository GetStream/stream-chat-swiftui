//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View previewing file attachments.
public struct FileAttachmentPreview: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Injected(\.fonts) private var fonts
    
    var url: URL
    
    @State private var isLoading = false
    @State private var title: String?
    @State private var error: Error?
    
    public var body: some View {
        NavigationView {
            ZStack {
                if error != nil {
                    Text("Error occured while previewing the file.")
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
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
