//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View displaying file attachments.
public struct FileAttachmentsView: View {

    @StateObject private var viewModel: FileAttachmentsViewModel

    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

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
                    imageName: "folder",
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
                                    FileAttachmentDisplayView(
                                        url: url,
                                        title: attachment.title ?? url.lastPathComponent,
                                        sizeString: attachment.file.sizeString
                                    )
                                    .onAppear {
                                        viewModel.loadAdditionalAttachments(
                                            after: monthlyDataSource,
                                            latest: attachment
                                        )
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical)
                                }
                                .sheet(item: $viewModel.selectedAttachment) { item in
                                    FileAttachmentPreview(url: item.assetURL)
                                }

                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(L10n.ChatInfo.Files.title)
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
