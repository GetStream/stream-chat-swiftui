//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View used for displaying progress while an attachment is being downloaded.
struct AttachmentDownloadingStateView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var downloadState: AttachmentDownloadingState
    var url: URL

    var body: some View {
        Group {
            switch downloadState.state {
            case let .downloading(progress: progress):
                BottomRightView {
                    PercentageProgressView(progress: progress)
                }

            case .downloadingFailed:
                BottomRightView {
                    Image(uiImage: images.messageListErrorIndicator)
                        .foregroundColor(Color(colors.alert))
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: -4, y: -4)
                }
            case .downloaded:
                EmptyView()
            }
        }
        .id("\(url.absoluteString)-\(downloadState.state))")
    }
}

/// View modifier enabling downloading state display.
struct AttachmentDownloadingStateViewModifier: ViewModifier {
    var downloadState: AttachmentDownloadingState?
    var url: URL

    func body(content: Content) -> some View {
        content
            .overlay(
                downloadState != nil ? AttachmentDownloadingStateView(downloadState: downloadState!, url: url) : nil
            )
    }
}

extension View {
    /// Attaches a downloading state indicator.
    /// - Parameters:
    ///  - downloadState: the download state of the attachment.
    ///  - url: the url of the attachment.
    public func withDownloadingStateIndicator(for downloadState: AttachmentDownloadingState?, url: URL) -> some View {
        modifier(AttachmentDownloadingStateViewModifier(downloadState: downloadState, url: url))
    }
}
