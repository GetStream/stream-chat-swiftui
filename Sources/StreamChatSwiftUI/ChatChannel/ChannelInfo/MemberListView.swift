//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// A view that displays the full member list for a group channel, presented as a sheet.
public struct MemberListView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.chatClient) private var chatClient

    let factory: Factory
    @ObservedObject var viewModel: ChatChannelInfoViewModel
    @State private var selectedParticipant: ParticipantInfo?
    @State private var addUsersShown = false

    public init(factory: Factory = DefaultViewFactory.shared, viewModel: ChatChannelInfoViewModel) {
        self.factory = factory
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.allParticipants) { participant in
                        ChatInfoMemberView(
                            factory: factory,
                            participant: participant,
                            backgroundColor: colors.backgroundCoreApp,
                            onAppear: { viewModel.onMemberAppear(participant) },
                            onTap: {
                                selectedParticipant = participant
                            }
                        )
                    }
                }
            }
            .background(Color(colors.backgroundCoreApp).edgesIgnoringSafeArea(.all))
            .toolbarThemed {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.memberListSheetShown = false
                    } label: {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .font(.system(size: 12))
                            .foregroundColor(Color(colors.buttonSecondaryText))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(L10n.ChatInfo.Members.count(viewModel.channel.memberCount))
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.navigationBarTitle))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.shouldShowAddMemberButton {
                        Button {
                            addUsersShown = true
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .renderingMode(.template)
                                .font(.system(size: 16))
                                .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
                        }
                        .modifier(factory.styles.makeToolbarConfirmActionModifier(options: .init()))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedParticipant) { participant in
            ParticipantInfoView(
                factory: factory,
                participant: participant,
                actions: viewModel.participantActions(for: participant)
            ) {
                selectedParticipant = nil
            }
            .modifier(PresentationDetentsModifier(sheetSizes: [.custom(280), .medium]))
        }
        .sheet(isPresented: $addUsersShown) {
            factory.makeMemberAddView(
                options: MemberAddViewOptions(
                    options: .init(loadedUserIds: viewModel.allMemberIds),
                    onConfirm: { users in
                        viewModel.addUsersTapped(users)
                        addUsersShown = false
                    }
                )
            )
        }
    }
}
