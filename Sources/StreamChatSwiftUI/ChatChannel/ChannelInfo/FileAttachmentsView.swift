//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying file attachments.
public struct FileAttachmentsView: View {
    @StateObject private var viewModel: FileAttachmentsViewModel

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.images) private var images
    @Injected(\.utils) private var utils
    @Injected(\.tokens) private var tokens

    public init(channel: ChatChannel) {
        _viewModel = StateObject(
            wrappedValue: FileAttachmentsViewModel(channel: channel)
        )
    }

    init(viewModel: FileAttachmentsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            if viewModel.loading {
                LoadingView()
            } else if viewModel.attachmentsDataSource.isEmpty {
                EmptyContentView(
                    image: images.noMedia,
                    title: L10n.ChatInfo.Files.emptyTitle,
                    description: L10n.ChatInfo.Files.emptyDesc
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.attachmentsDataSource) { monthlyDataSource in
                            ForEach(monthlyDataSource.attachments) { attachment in
                                let url = attachment.assetURL

                                Button {
                                    viewModel.selectedAttachment = attachment
                                } label: {
                                    HStack {
                                        FileAttachmentDisplayView(
                                            url: url,
                                            title: attachment.title ?? url.lastPathComponent,
                                            sizeString: attachment.file.sizeString
                                        )
                                        Spacer()
                                    }
                                    .onAppear {
                                        viewModel.loadAdditionalAttachments(
                                            after: monthlyDataSource,
                                            latest: attachment
                                        )
                                    }
                                }
                                .padding(.vertical, tokens.spacingSm)
                                .padding(.horizontal)
                                .sheet(item: $viewModel.selectedAttachment) { item in
                                    FileAttachmentPreview(attachment: item)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(colors.backgroundCoreApp.toColor)
        .toolbarThemed {
            ToolbarItem(placement: .principal) {
                Text(L10n.ChatInfo.Files.title)
                    .font(fonts.bodyBold)
                    .foregroundColor(Color(colors.navigationBarTitle))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
