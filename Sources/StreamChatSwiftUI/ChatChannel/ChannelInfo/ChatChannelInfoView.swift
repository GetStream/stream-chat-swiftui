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

    private enum AlertType: Identifiable {
        case blockUser, leaveConversation, error
        var id: Self { self }
    }

    @State private var alertType: AlertType?

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
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.top, tokens.spacingXl)
                    .padding(.bottom, tokens.spacingXl)

                VStack(spacing: tokens.spacingMd) {
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
            EditGroupView(factory: factory, viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.addUsersShown) {
            factory.makeMemberAddView(
                options: MemberAddViewOptions(
                    options: .init(loadedUserIds: viewModel.allMemberIds),
                    onConfirm: viewModel.addUsersTapped(_:)
                )
            )
        }
        .sheet(item: $viewModel.selectedParticipant) { participant in
            ParticipantInfoView(
                factory: factory,
                participant: participant,
                actions: viewModel.participantActions(for: participant)
            ) {
                viewModel.selectedParticipant = nil
            }
            .modifier(PresentationDetentsModifier(sheetSizes: [.custom(280), .medium]))
        }
        .onChange(of: viewModel.errorShown) { shown in
            if shown { alertType = .error }
        }
        .alert(item: $alertType) { type -> Alert in
            switch type {
            case .blockUser:
                return Alert(
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
            case .leaveConversation:
                return Alert(
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
            case .error:
                return Alert(
                    title: Text(L10n.Alert.Error.title),
                    message: Text(L10n.Alert.Error.message),
                    dismissButton: .cancel(Text(L10n.Alert.Actions.ok)) {
                        viewModel.errorShown = false
                    }
                )
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        if viewModel.showSingleMemberDMView, let participant = viewModel.displayedParticipants.first {
            ChatInfoDirectMessageView(
                factory: factory,
                participant: participant
            )
        } else {
            ChatInfoGroupHeaderView(factory: factory, viewModel: viewModel)
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
                icon: images.imagePlaceholder,
                title: L10n.ChatInfo.Media.title
            ) {
                MediaAttachmentsView(factory: factory, channel: viewModel.channel)
            }

            NavigatableChatInfoItemView(
                icon: images.folder,
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
            membersCardHeader

            membersList

            Spacer()
                .frame(height: tokens.spacingSm)

            if viewModel.showMoreUsersButton {
                viewAllButton
            }
        }
        .background(colors.backgroundCoreSurfaceSubtle.toColor)
        .cornerRadius(16)
    }

    private var membersCardHeader: some View {
        HStack {
            Text(L10n.ChatInfo.Members.count(viewModel.channel.memberCount))
                .font(fonts.headline)
                .foregroundColor(Color(colors.textPrimary))

            Spacer()

            if viewModel.shouldShowAddUserButton {
                StreamTextButton(role: .secondary, style: .outline, size: .small) {
                    viewModel.addUsersShown = true
                } text: {
                    Text(L10n.ChatInfo.Members.add)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.buttonSecondaryText))
                }
            }
        }
        .padding(.horizontal, tokens.spacingMd)
        .padding(.top, tokens.spacingMd)
        .padding(.bottom, tokens.spacingXs)
        .background(Color(colors.backgroundCoreSurfaceSubtle))
    }

    private var membersList: some View {
        ForEach(viewModel.displayedParticipants) { participant in
            ChatInfoMemberView(
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
    }

    private var viewAllButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(colors.borderCoreDefault))
            Button {
                viewModel.memberListSheetShown = true
            } label: {
                Text(L10n.ChatInfo.Users.viewAll)
                    .font(fonts.body.weight(.semibold))
                    .foregroundColor(Color(colors.buttonSecondaryText))
                    .frame(maxWidth: .infinity)
                    .frame(height: tokens.buttonHitTargetMinHeight)
            }
        }
    }

    // MARK: - Actions Card

    @ViewBuilder
    private var actionsCard: some View {
        if viewModel.shouldShowMuteChannelButton || viewModel.shouldShowBlockUserButton || viewModel.shouldShowLeaveConversationButton {
            InfoSectionCard {
                if viewModel.shouldShowMuteChannelButton {
                    ChannelInfoItemView(
                        icon: images.muted,
                        title: viewModel.mutedText
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
        }
    }

    private var blockButton: some View {
        Button {
            alertType = .blockUser
        } label: {
            HStack(spacing: tokens.spacingMd) {
                Image(uiImage: images.messageActionBlockUser)
                    .customizable()
                    .frame(width: tokens.spacingLg)
                Text(viewModel.blockUserTitle)
                Spacer()
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingMd)
            .font(fonts.body)
            .foregroundColor(Color(colors.textPrimary))
            .background(Color(colors.backgroundCoreSurfaceSubtle))
        }
    }

    private var leaveButton: some View {
        Button {
            alertType = .leaveConversation
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
            .foregroundColor(Color(colors.accentError))
            .background(Color(colors.backgroundCoreSurfaceSubtle))
        }
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
                editButton
            }
        }
    }

    @ViewBuilder
    private var editButton: some View {
        if #available(iOS 26.0, *) {
            StreamTextButton(role: .secondary, style: .ghost, size: .medium) {
                viewModel.editGroupShown = true
            } text: {
                Text(L10n.ChatInfo.edit)
                    .font(fonts.bodyBold)
            }
            .modifier(LiquidGlassBorderlessModifier(shape: Capsule(), isInteractive: true))
        } else {
            StreamTextButton(role: .secondary, style: .outline, size: .medium) {
                viewModel.editGroupShown = true
            } text: {
                Text(L10n.ChatInfo.edit)
                    .font(fonts.bodyBold)
            }
        }
    }
}
