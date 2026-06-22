//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Full-sheet view for adding members to a channel.
/// Supports search, pagination, and multi-select with a batch confirm action.
public struct MemberAddView<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors

    @Environment(\.presentationMode) private var presentationMode

    private let factory: Factory
    @StateObject private var viewModel: MemberAddViewModel
    var onConfirm: @MainActor ([ChatUser]) -> Void

    public init(
        factory: Factory = DefaultViewFactory.shared,
        loadedUserIds: [String],
        onConfirm: @escaping @MainActor ([ChatUser]) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: MemberAddViewModel(loadedUserIds: loadedUserIds)
        )
        self.onConfirm = onConfirm
        self.factory = factory
    }

    init(
        factory: Factory = DefaultViewFactory.shared,
        viewModel: MemberAddViewModel,
        onConfirm: @escaping @MainActor ([ChatUser]) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onConfirm = onConfirm
        self.factory = factory
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.users) { user in
                        AddMembersUserRow(
                            factory: factory,
                            user: user,
                            isSelected: viewModel.isSelected(user),
                            isAlreadyMember: viewModel.isAlreadyMember(user)
                        ) {
                            viewModel.toggleUser(user)
                        }
                        .onAppear {
                            viewModel.onUserAppear(user)
                        }
                    }
                }
            }
            .modifier(factory.styles.makeSearchableModifier(
                options: SearchableModifierOptions(searchText: $viewModel.searchText)
            ))
            .background(Color(colors.backgroundCoreApp).edgesIgnoringSafeArea(.all))
            .modifier(
                MemberAddToolbarModifier(
                    factory: factory,
                    viewModel: viewModel,
                    onConfirm: { onConfirm(viewModel.selectedUsers) },
                    onDismiss: { presentationMode.wrappedValue.dismiss() }
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// Options used in the member add view.
public final class MemberAddOptions: Sendable {
    public let loadedUserIds: [String]

    public init(loadedUserIds: [String]) {
        self.loadedUserIds = loadedUserIds
    }
}

// MARK: - User Row

private struct AddMembersUserRow<Factory: ViewFactory>: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens
    @Injected(\.images) private var images

    let factory: Factory
    let user: ChatUser
    let isSelected: Bool
    let isAlreadyMember: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: { if !isAlreadyMember { onTap() } }) {
            HStack(spacing: tokens.spacingSm) {
                factory.makeUserAvatarView(
                    options: UserAvatarViewOptions(
                        user: user,
                        size: AvatarSize.large,
                        showsIndicator: false
                    )
                )

                VStack(alignment: .leading, spacing: tokens.spacingXxxs) {
                    Text(user.name ?? user.id)
                        .font(fonts.body)
                        .foregroundColor(Color(colors.textPrimary))
                        .lineLimit(1)

                    if isAlreadyMember {
                        Text(L10n.ChatInfo.Members.alreadyMember)
                            .font(fonts.footnote)
                            .foregroundColor(Color(colors.textTertiary))
                    }
                }

                Spacer()

                if !isAlreadyMember {
                    selectionIndicator
                }
            }
            .padding(.horizontal, tokens.spacingMd)
            .padding(.vertical, tokens.spacingXs)
            .background(Color(colors.backgroundCoreApp))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var selectionIndicator: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color(colors.accentPrimary))
                    .frame(width: 24, height: 24)
                Image(uiImage: images.selectionBadgeIcon)
                    .customizable()
                    .frame(width: tokens.iconSizeXs)
                    .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
            } else {
                Circle()
                    .strokeBorder(Color(colors.borderCoreSubtle), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

// MARK: - Toolbar

private struct MemberAddToolbarModifier<Factory: ViewFactory>: ViewModifier {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    @Injected(\.tokens) private var tokens

    let factory: Factory
    @ObservedObject var viewModel: MemberAddViewModel
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbarThemed {
                toolbarContent()
            }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .font(.system(size: 12))
                    .foregroundColor(Color(colors.buttonSecondaryText))
            }
        }

        ToolbarItem(placement: .principal) {
            Text(L10n.ChatInfo.Members.addMembersTitle)
                .font(fonts.bodyBold)
                .foregroundColor(Color(colors.navigationBarTitle))
        }

        ToolbarItem(placement: .topBarTrailing) {
            confirmButton
        }
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Image(systemName: "checkmark")
                .renderingMode(.template)
                .font(.system(size: 16))
                .foregroundColor(Color(colors.buttonPrimaryTextOnAccent))
        }
        .modifier(factory.styles.makeToolbarConfirmActionModifier(options: .init()))
    }
}
