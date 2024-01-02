//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// View model for the `FileAttachmentsView`.
class FileAttachmentsViewModel: ObservableObject {

    @Published var loading = false
    @Published var attachmentsDataSource = [MonthlyFileAttachments]()
    @Published var selectedAttachment: ChatMessageFileAttachment?

    @Injected(\.chatClient) private var chatClient

    private let channel: ChatChannel
    private var messageSearchController: ChatMessageSearchController!

    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()

    private var loadingNextMessages = false

    init(channel: ChatChannel) {
        self.channel = channel

        dateFormatter.dateFormat = "MMMM yyyy"
        messageSearchController = chatClient.messageSearchController()
        loadMessages()
    }

    init(channel: ChatChannel, messageSearchController: ChatMessageSearchController) {
        self.channel = channel

        dateFormatter.dateFormat = "MMMM yyyy"
        self.messageSearchController = messageSearchController
        loadMessages()
    }

    func loadAdditionalAttachments(after: MonthlyFileAttachments, latest: ChatMessageFileAttachment) {
        guard let index = attachmentsDataSource.firstIndex(where: { monthly in
            monthly.id == after.id
        }) else {
            return
        }

        var totalRemaining = 0
        if let attachmentIndex = attachmentsDataSource[index].attachments.firstIndex(where: { attachment in
            attachment.id == latest.id
        }) {
            totalRemaining = attachmentsDataSource[index].attachments.count - attachmentIndex
        }

        let next = index + 1
        if next < attachmentsDataSource.count {
            for i in next..<attachmentsDataSource.count {
                totalRemaining += attachmentsDataSource[i].attachments.count
            }
        }

        if totalRemaining > 10 {
            return
        }

        if !loadingNextMessages {
            loadingNextMessages = true
            messageSearchController.loadNextMessages { [weak self] _ in
                guard let self = self else { return }
                self.updateAttachments()
                self.loadingNextMessages = false
            }
        }
    }

    private func loadMessages() {
        let query = MessageSearchQuery(
            channelFilter: .equal(.cid, to: channel.cid),
            messageFilter: .withAttachments([.file])
        )

        loading = true
        messageSearchController.search(query: query, completion: { [weak self] _ in
            guard let self = self else { return }
            self.updateAttachments()
            self.loading = false
        })
    }

    private func updateAttachments() {
        let messages = messageSearchController.messages
        withAnimation {
            self.attachmentsDataSource = self.loadAttachments(from: messages)
        }
    }

    private func loadAttachments(from messages: LazyCachedMapCollection<ChatMessage>) -> [MonthlyFileAttachments] {
        var attachmentMappings = [String: [ChatMessageFileAttachment]]()
        var monthAndYearArray = [String]()

        for message in messages {
            let date = message.createdAt
            let displayName = dateFormatter.string(from: date)

            if !monthAndYearArray.contains(displayName) {
                monthAndYearArray.append(displayName)
            }

            var attachmentsForMonth = attachmentMappings[displayName] ?? []
            attachmentsForMonth.append(contentsOf: message.fileAttachments)
            attachmentMappings[displayName] = attachmentsForMonth
        }

        var result = [MonthlyFileAttachments]()
        for month in monthAndYearArray {
            let attachments = attachmentMappings[month] ?? []
            let monthlyAttachments = MonthlyFileAttachments(
                monthAndYear: month,
                attachments: attachments
            )
            result.append(monthlyAttachments)
        }

        return result
    }
}

struct MonthlyFileAttachments: Identifiable {
    var id: String {
        monthAndYear
    }

    let monthAndYear: String
    let attachments: [ChatMessageFileAttachment]
}
