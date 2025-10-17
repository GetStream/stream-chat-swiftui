//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// View for the channel info screen.
public struct ChatChannelInfoView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts

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
                LazyVStack(spacing: 0) {
                    if viewModel.showSingleMemberDMView {
                        ChatInfoDirectChannelView(
                            factory: factory,
                            participant: viewModel.displayedParticipants.first
                        )
                    } else {
                        ChatInfoParticipantsView(
                            factory: factory,
                            participants: viewModel.displayedParticipants,
                            onItemAppear: viewModel.onParticipantAppear(_:),
                            selectedParticipant: $viewModel.selectedParticipant
                        )
                    }

                    if viewModel.showMoreUsersButton {
                        ChatChannelInfoButton(
                            title: viewModel.showMoreUsersButtonTitle,
                            iconName: "chevron.down",
                            foregroundColor: Color(colors.textLowEmphasis)
                        ) {
                            viewModel.memberListCollapsed = false
                        }
                    }

                    ChannelInfoDivider()

                    ChatInfoOptionsView(factory: factory, viewModel: viewModel)

                    ChannelInfoDivider()
                        .alert(isPresented: $viewModel.errorShown) {
                            Alert.defaultErrorAlert
                        }

                    if viewModel.shouldShowLeaveConversationButton {
                        ChatChannelInfoButton(
                            title: viewModel.leaveButtonTitle,
                            iconName: "person.fill.xmark",
                            foregroundColor: Color(colors.alert)
                        ) {
                            viewModel.leaveGroupAlertShown = true
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
                }
            }
            .overlay(
                popupShown ?
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all) : nil
            )
            .blur(radius: popupShown ? 6 : 0)
            .allowsHitTesting(!popupShown)

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
                        options: .init(loadedUsers: viewModel.participants.map(\.chatUser)),
                        onUserTap: viewModel.addUserTapped(_:)
                    )
                }
            }
            
            if let selectedParticipant = viewModel.selectedParticipant {
                ParticipantInfoView(
                    participant: selectedParticipant,
                    actions: viewModel.participantActions(for: selectedParticipant)
                ) {
                    withAnimation {
                        viewModel.selectedParticipant = nil
                    }
                }
            }
        }
        .modifier(ChatChannelInfoViewHeaderViewModifier(viewModel: viewModel))
        .onReceive(keyboardWillChangePublisher) { visible in
            viewModel.keyboardShown = visible
        }
        .dismissKeyboardOnTap(enabled: viewModel.keyboardShown)
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
    }
    
    private var popupShown: Bool {
        viewModel.addUsersShown || viewModel.selectedParticipant != nil
    }
}

struct ChatChannelInfoViewHeaderViewModifier: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let viewModel: ChatChannelInfoViewModel
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .toolbarThemed {
                    toolbar(glyphSize: 24)
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
    
    @ToolbarContentBuilder func toolbar(glyphSize: CGFloat? = nil) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Group {
                if viewModel.showSingleMemberDMView {
                    Text(viewModel.displayedParticipants.first?.chatUser.name ?? "")
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.navigationBarTitle))
                } else {
                    ChannelTitleView(
                        channel: viewModel.channel,
                        shouldShowTypingIndicator: false
                    )
                    .id(viewModel.channelId)
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.shouldShowAddUserButton {
                Button {
                    viewModel.addUsersShown = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .customizable()
                        .frame(width: glyphSize, height: glyphSize)
                        .foregroundColor(Color(colors.navigationBarGlyph))
                        .padding(.all, 8)
                        .background(colors.navigationBarTintColor)
                        .clipShape(Circle())
                }
            }
        }
    }
}
