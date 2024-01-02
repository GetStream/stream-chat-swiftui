//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for displaying progress while an asset is being uploaded.
struct AttachmentUploadingStateView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var uploadState: AttachmentUploadingState
    var url: URL

    var body: some View {
        Group {
            switch uploadState.state {
            case let .uploading(progress: progress):
                BottomRightView {
                    HStack(spacing: 4) {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .white)
                            )
                            .scaleEffect(0.7)

                        Text(progressDisplay(for: progress))
                            .font(fonts.footnote)
                            .foregroundColor(Color(colors.staticColorText))
                    }
                    .padding(.all, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.all, 8)
                }

            case .uploadingFailed:
                BottomRightView {
                    Image(uiImage: images.messageListErrorIndicator)
                        .foregroundColor(Color(colors.alert))
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: -4, y: -4)
                }
            case .uploaded:
                TopRightView {
                    Image(uiImage: images.confirmCheckmark)
                        .renderingMode(.template)
                        .foregroundColor(Color.black.opacity(0.7))
                        .padding(.all, 8)
                }

            default:
                EmptyView()
            }
        }
        .id("\(url.absoluteString)-\(uploadState.state))")
    }

    private func progressDisplay(for progress: CGFloat) -> String {
        let value = Int(progress * 100)
        return "\(value)%"
    }
}

/// View modifier enabling uploading state display.
struct AttachmentUploadingStateViewModifier: ViewModifier {
    var uploadState: AttachmentUploadingState?
    var url: URL

    func body(content: Content) -> some View {
        content
            .overlay(
                uploadState != nil ? AttachmentUploadingStateView(uploadState: uploadState!, url: url) : nil
            )
    }
}

extension View {
    /// Attaches a uploading state indicator.
    /// - Parameters:
    ///  - uploadState: the upload state of the asset.
    ///  - url: the url of the asset.
    public func withUploadingStateIndicator(for uploadState: AttachmentUploadingState?, url: URL) -> some View {
        modifier(AttachmentUploadingStateViewModifier(uploadState: uploadState, url: url))
    }
}
