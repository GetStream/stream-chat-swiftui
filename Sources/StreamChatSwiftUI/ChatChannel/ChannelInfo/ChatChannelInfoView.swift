//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// View for the channel info screen.
public struct ChatChannelInfoView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.chatClient) private var chatClient

    let factory: Factory

    @StateObject private var viewModel: ChatChannelInfoViewModel
    private var shownFromMessageList: Bool

    @Environment(\.presentationMode) var presentationMode

    public init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelInfoViewModel? = nil,
        channel: ChatChannel,
        shownFromMessageList: Bool = false
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ChatChannelInfoViewModel(channel: channel)
        )
        self.factory = factory
        self.shownFromMessageList = shownFromMessageList
    }

    init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: ChatChannelInfoViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.factory = factory
        shownFromMessageList = false
    }

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, tokens.spacingXl)
                        .padding(.bottom, tokens.spacingLg)

                    VStack(spacing: tokens.spacingSm) {
                        navigationLinksCard

                        if !viewModel.showSingleMemberDMView {
                            membersCard
                        }

                        actionsCard
                    }
                    .padding(.horizontal, tokens.spacingMd)
                    .padding(.bottom, tokens.spacing2xl)
                }
            }
            .overlay(
                viewModel.addUsersShown ?
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all) : nil
            )
            .blur(radius: viewModel.addUsersShown ? 6 : 0)
            .allowsHitTesting(!viewModel.addUsersShown)

            if viewModel.addUsersShown {
                VStack {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .layoutPriority(-1)
                        .onTapGesture {
                            viewModel.addUsersShown = false
                        }
                        .accessibilityAction {
                            viewModel.addUsersShown = false
                        }

                    factory.makeAddUsersView(
                        options: AddUsersViewOptions(
                            options: .init(loadedUsers: viewModel.participants.map(\.chatUser)),
                            onUserTap: viewModel.addUserTapped(_:)
                        )
                    )
                }
            }
        }
        .modifier(ChatChannelInfoViewHeaderViewModifier(viewModel: viewModel))
        .onReceive(keyboardWillChangePublisher) { visible in
            viewModel.keyboardShown = visible
        }
        .dismissKeyboardOnTap(enabled: viewModel.keyboardShown)
        .background(Color(colors.backgroundCoreApp).edgesIgnoringSafeArea(.bottom))
        .sheet(isPresented: $viewModel.memberListSheetShown) {
            MemberListView(factory: factory, viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.editGroupShown) {
            EditGroupView(viewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedParticipant) { participant in
            ParticipantInfoView(
                factory: factory,
                participant: participant,
                actions: viewModel.participantActions(for: participant)
            ) {
                viewModel.selectedParticipant = nil
            }
            .modifier(PresentationDetentsModifier(sheetSizes: [.custom(250), .medium]))
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        if viewModel.showSingleMemberDMView {
            ChatInfoDirectChannelView(
                factory: factory,
                participant: viewModel.displayedParticipants.first
            )
        } else {
            ChatInfoGroupHeaderView(viewModel: viewModel)
        }
    }

    // MARK: - Navigation Links Card

    private var navigationLinksCard: some View {
        InfoSectionCard {
            NavigatableChatInfoItemView(
                icon: images.pin,
                title: L10n.ChatInfo.PinnedMessages.title
            ) {
                PinnedMessagesView(
                    factory: factory,
                    channel: viewModel.channel,
                    channelController: viewModel.channelController
                )
            }

            NavigatableChatInfoItemView(
                icon: UIImage(systemName: "photo")!,
                title: L10n.ChatInfo.Media.title
            ) {
                MediaAttachmentsView(factory: factory, channel: viewModel.channel)
            }

            NavigatableChatInfoItemView(
                icon: UIImage(systemName: "folder")!,
                title: L10n.ChatInfo.Files.title
            ) {
                FileAttachmentsView(channel: viewModel.channel)
            }
        }
    }

    // MARK: - Members Card

    @ViewBuilder
    private var membersCard: some View {
        InfoSectionCard {
            ForEach(Array(viewModel.displayedParticipants.enumerated()), id: \.element.id) { _, participant in
                ChatInfoMemberRow(
                    factory: factory,
                    participant: participant,
                    onAppear: { viewModel.onParticipantAppear(participant) },
                    onTap: {
                        withAnimation {
                            viewModel.selectedParticipant = participant
                        }
                    }
                )
            }
            if viewModel.showMoreUsersButton {
                StreamTextButton(role: .secondary, style: .outline, size: .small) {
                    viewModel.memberListSheetShown = true
                } text: {
                    Text(L10n.ChatInfo.Users.viewAll)
                        .font(fonts.bodyBold)
                }
                .padding(.vertical, tokens.spacingXs)
            }
        }
        .padding(.vertical, tokens.spacingXs)
        .background(colors.backgroundCoreSurfaceCard.toColor)
        .cornerRadius(16)
    }

    // MARK: - Actions Card

    @ViewBuilder
    private var actionsCard: some View {
        if viewModel.shouldShowMuteChannelButton || viewModel.shouldShowBlockUserButton || viewModel.shouldShowLeaveConversationButton {
            InfoSectionCard {
                if viewModel.shouldShowMuteChannelButton {
                    ChannelInfoItemView(
                        icon: images.muted,
                        title: viewModel.mutedText,
                        verticalPadding: tokens.spacingMd
                    ) {
                        Toggle(isOn: $viewModel.muted) {
                            EmptyView()
                        }
                    }
                }

                if viewModel.shouldShowBlockUserButton {
                    blockButton
                }

                if viewModel.shouldShowLeaveConversationButton {
                    leaveButton
                }
            }
            .alert(isPresented: $viewModel.errorShown) {
                Alert.defaultErrorAlert
            }
        }
    }

    private var blockButton: some View {
        Button {
            viewModel.blockUserAlertShown = true
        } label: {
            HStack(spacing: tokens.spacingMd) {
                Image(systemName: "circle.slash")
                    .customizable()
                    .frame(width: tokens.spacingLg)
                Text(viewModel.blockUserTitle)
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .background(Color(colors.backgroundCoreSurfaceCard))
        }
        .alert(isPresented: $viewModel.blockUserAlertShown) {
            Alert(
                title: Text(viewModel.blockUserTitle),
                message: Text(
                    viewModel.isDMUserBlocked
                        ? L10n.Message.Actions.UserUnblock.confirmationMessage
                        : L10n.Message.Actions.UserBlock.confirmationMessage
                ),
                primaryButton: .destructive(Text(viewModel.blockUserTitle)) {
                    viewModel.blockUserTapped()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var leaveButton: some View {
        Button {
            viewModel.leaveGroupAlertShown = true
        } label: {
            HStack(spacing: tokens.spacingMd) {
                Image(systemName: viewModel.showSingleMemberDMView ? "trash" : "rectangle.portrait.and.arrow.right")
                    .customizable()
                    .frame(width: tokens.spacingLg)
                Text(viewModel.leaveButtonTitle)
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
            .font(fonts.body)
            .foregroundColor(Color(colors.alert))
            .background(Color(colors.backgroundCoreSurfaceCard))
        }
        .alert(isPresented: $viewModel.leaveGroupAlertShown) {
            Alert(
                title: Text(viewModel.leaveButtonTitle),
                message: Text(viewModel.leaveConversationDescription),
                primaryButton: .destructive(Text(viewModel.leaveButtonTitle)) {
                    viewModel.leaveConversationTapped {
                        presentationMode.wrappedValue.dismiss()
                        if shownFromMessageList {
                            notifyChannelDismiss()
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var popupShown: Bool {
        viewModel.addUsersShown
    }
}

// MARK: - Toolbar

struct ChatChannelInfoViewHeaderViewModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

    @ObservedObject var viewModel: ChatChannelInfoViewModel

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .toolbarThemed {
                    toolbar()
                    #if compiler(>=6.2)
                        .sharedBackgroundVisibility(.hidden)
                    #endif
                }
        } else {
            content
                .toolbarThemed {
                    toolbar()
                }
        }
    }

    @ToolbarContentBuilder func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(viewModel.showSingleMemberDMView ? L10n.ChatInfo.Contact.title : L10n.ChatInfo.Group.title)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if !viewModel.showSingleMemberDMView {
                StreamTextButton(role: .secondary, style: .outline, size: .small) {
                    viewModel.editGroupShown = true
                } text: {
                    Text(L10n.ChatInfo.edit)
                        .font(fonts.bodyBold)
                }
            }
        }
    }
}
