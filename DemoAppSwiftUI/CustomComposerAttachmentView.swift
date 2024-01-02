//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatSwiftUI
import SwiftUI

extension AttachmentType {
    static let contact = Self(rawValue: "contact")
}

struct ContactAttachmentPayload: AttachmentPayload {
    static let type: AttachmentType = .contact

    let name: String
    let phoneNumber: String
}

extension ContactAttachmentPayload: Identifiable {

    var id: String {
        "\(name)-\(phoneNumber)"
    }
}

class CustomAttachmentsFactory: ViewFactory {

    @Injected(\.chatClient) var chatClient: ChatClient

    private let mockContacts = [
        CustomAttachment(
            id: "123",
            content: AnyAttachmentPayload(payload: ContactAttachmentPayload(name: "Test 1", phoneNumber: "071234234232"))
        ),
        CustomAttachment(
            id: "124",
            content: AnyAttachmentPayload(payload: ContactAttachmentPayload(name: "Test 2", phoneNumber: "4323243423432"))
        ),
        CustomAttachment(
            id: "125",
            content: AnyAttachmentPayload(payload: ContactAttachmentPayload(name: "Test 3", phoneNumber: "75756756756756"))
        ),
        CustomAttachment(
            id: "126",
            content: AnyAttachmentPayload(payload: ContactAttachmentPayload(name: "Test 4", phoneNumber: "534543674576565"))
        ),
        CustomAttachment(
            id: "127",
            content: AnyAttachmentPayload(payload: ContactAttachmentPayload(name: "Test 5", phoneNumber: "534534543543534"))
        )
    ]

    func makeAttachmentSourcePickerView(
        selected: AttachmentPickerState,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void
    ) -> some View {
        CustomAttachmentSourcePickerView(
            selected: selected,
            onTap: onPickerStateChange
        )
    }

    func makeCustomAttachmentView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> some View {
        CustomContactAttachmentView(
            contacts: mockContacts,
            addedContacts: addedCustomAttachments,
            onCustomAttachmentTap: onCustomAttachmentTap
        )
    }

    func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> some View {
        let contactAttachments = message.attachments(payloadType: ContactAttachmentPayload.self)
        return VStack {
            ForEach(0..<contactAttachments.count, id: \.self) { i in
                let contact = contactAttachments[i]
                CustomContactAttachmentPreview(
                    contact: CustomAttachment(
                        id: "\(message.id)-\(i)",
                        content: AnyAttachmentPayload(payload: contact.payload)
                    ),
                    payload: contact.payload,
                    onCustomAttachmentTap: { _ in },
                    isAttachmentSelected: false,
                    hasSpacing: false
                )
                .standardPadding()
            }
            .messageBubble(for: message, isFirst: true)
        }
    }

    func makeCustomAttachmentPreviewView(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) -> some View {
        CustomContactAttachmentComposerPreview(
            addedCustomAttachments: addedCustomAttachments,
            onCustomAttachmentTap: onCustomAttachmentTap
        )
    }
}

class CustomMessageTypeResolver: MessageTypeResolving {

    func hasCustomAttachment(message: ChatMessage) -> Bool {
        let contactAttachments = message.attachments(payloadType: ContactAttachmentPayload.self)
        return !contactAttachments.isEmpty
    }
}

struct CustomAttachmentSourcePickerView: View {

    @Injected(\.colors) var colors
    @Injected(\.images) var images

    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            AttachmentPickerButton(
                icon: images.attachmentPickerPhotos,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )

            AttachmentPickerButton(
                icon: images.attachmentPickerFolder,
                pickerType: .files,
                isSelected: selected == .files,
                onTap: onTap
            )

            AttachmentPickerButton(
                icon: images.attachmentPickerCamera,
                pickerType: .camera,
                isSelected: selected == .camera,
                onTap: onTap
            )

            AttachmentPickerButton(
                icon: UIImage(systemName: "person.crop.circle")!,
                pickerType: .custom,
                isSelected: selected == .custom,
                onTap: onTap
            )

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(colors.background1))
    }
}

struct CustomContactAttachmentView: View {

    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors

    let contacts: [CustomAttachment]
    let addedContacts: [CustomAttachment]
    var onCustomAttachmentTap: (CustomAttachment) -> Void

    var body: some View {
        AttachmentTypeContainer {
            VStack(alignment: .leading) {
                Text("Contacts")
                    .font(fonts.headlineBold)
                    .standardPadding()

                ScrollView {
                    VStack {
                        ForEach(contacts) { contact in
                            if let payload = contact.content.payload as? ContactAttachmentPayload {
                                CustomContactAttachmentPreview(
                                    contact: contact,
                                    payload: payload,
                                    onCustomAttachmentTap: onCustomAttachmentTap,
                                    isAttachmentSelected: addedContacts.contains(contact)
                                )
                                .padding(.all, 4)
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct CustomContactAttachmentComposerPreview: View {

    var addedCustomAttachments: [CustomAttachment]
    var onCustomAttachmentTap: (CustomAttachment) -> Void

    var body: some View {
        VStack {
            ForEach(addedCustomAttachments) { contact in
                if let payload = contact.content.payload as? ContactAttachmentPayload {
                    HStack {
                        CustomContactAttachmentPreview(
                            contact: contact,
                            payload: payload,
                            onCustomAttachmentTap: onCustomAttachmentTap,
                            isAttachmentSelected: false
                        )
                        .padding(.leading, 8)

                        Spacer()

                        DiscardAttachmentButton(
                            attachmentIdentifier: payload.id,
                            onDiscard: { _ in
                                onCustomAttachmentTap(contact)
                            }
                        )
                    }
                    .padding(.all, 4)
                    .roundWithBorder()
                    .padding(.all, 2)
                }
            }
        }
    }
}

struct CustomContactAttachmentPreview: View {

    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors

    let contact: CustomAttachment
    let payload: ContactAttachmentPayload
    var onCustomAttachmentTap: (CustomAttachment) -> Void
    var isAttachmentSelected: Bool
    var hasSpacing = true

    var body: some View {
        Button {
            withAnimation {
                onCustomAttachmentTap(contact)
            }
        } label: {
            HStack {
                Image(systemName: "person.crop.circle")
                    .renderingMode(.template)
                    .foregroundColor(Color(colors.textLowEmphasis))

                VStack(alignment: .leading) {
                    Text(payload.name)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.text))
                    Text(payload.phoneNumber)
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }

                if hasSpacing {
                    Spacer()
                }

                if isAttachmentSelected {
                    Image(systemName: "checkmark")
                        .renderingMode(.template)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }
        }
    }
}
