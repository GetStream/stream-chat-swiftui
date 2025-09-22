//
// Copyright © 2025 Stream.io Inc. All rights reserved.
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
                NoContentView(
                    image: images.noMedia,
                    title: L10n.ChatInfo.Files.emptyTitle,
                    description: L10n.ChatInfo.Files.emptyDesc
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.attachmentsDataSource) { monthlyDataSource in
                            MonthlyAttachmentsHeader(monthlyDataSource: monthlyDataSource)

                            ForEach(monthlyDataSource.attachments, id: \.self) { attachment in
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
                                        if utils.messageListConfig.downloadFileAttachmentsEnabled {
                                            DownloadShareAttachmentView(attachment: attachment)
                                        }
                                    }
                                    .onAppear {
                                        viewModel.loadAdditionalAttachments(
                                            after: monthlyDataSource,
                                            latest: attachment
                                        )
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical)
                                }
                                .withDownloadingStateIndicator(for: attachment.downloadingState, url: attachment.assetURL)
                                .sheet(item: $viewModel.selectedAttachment) { item in
                                    FileAttachmentPreview(title: item.title, url: item.assetURL)
                                }

                                Divider()
                            }
                        }
                    }
                }
            }
        }
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

struct MonthlyAttachmentsHeader: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    var monthlyDataSource: MonthlyFileAttachments

    var body: some View {
        HStack {
            Text(monthlyDataSource.monthAndYear)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.textLowEmphasis))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

            Spacer()
        }
        .background(Color(colors.background6))
    }
}

extension ChatMessageFileAttachment: Identifiable {}
