//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the message actions.
public struct MessageActionsView: View {
    @Injected(\.colors) private var colors

    @StateObject var viewModel: MessageActionsViewModel
    var bundle: Bundle?

    public init(
        messageActions: [MessageAction],
        bundle: Bundle? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: ViewModelsFactory
                .makeMessageActionsViewModel(messageActions: messageActions)
        )
        self.bundle = bundle
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(actionRows) { row in
                let action = row.action

                if row.showsDivider {
                    Divider()
                }

                VStack(spacing: 0) {
                    if let destination = action.navigationDestination {
                        NavigationLink {
                            destination
                        } label: {
                            ActionItemView(
                                title: action.title,
                                iconName: action.iconName,
                                isDestructive: action.isDestructive,
                                boldTitle: false,
                                bundle: bundle
                            )
                        }
                        .accessibilityLabel(action.title)
                    } else {
                        Button {
                            if action.confirmationPopup != nil {
                                viewModel.alertAction = action
                            } else {
                                action.action()
                            }
                        } label: {
                            ActionItemView(
                                title: action.title,
                                iconName: action.iconName,
                                isDestructive: action.isDestructive,
                                boldTitle: false,
                                bundle: bundle
                            )
                        }
                        .accessibilityLabel(action.title)
                    }
                }
                .padding(.leading)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("messageAction-\(action.id)")
            }
        }
        .background(Color(colors.backgroundCoreElevation2))
        .roundWithBorder(cornerRadius: 12)
        .alert(isPresented: $viewModel.alertShown) {
            let title = viewModel.alertAction?.confirmationPopup?.title ?? ""
            let message = viewModel.alertAction?.confirmationPopup?.message ?? ""
            let buttonTitle = viewModel.alertAction?.confirmationPopup?.buttonTitle ?? ""

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .destructive(Text(buttonTitle)) {
                    viewModel.alertAction?.action()
                },
                secondaryButton: .cancel()
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MessageActionsView")
    }

    /// The divider goes in front of the trailing run of destructive actions, and is skipped
    /// when there is nothing above it to separate from.
    private var actionRows: [ActionRow] {
        let actions = viewModel.messageActions
        var dividerIndex: Int?
        if let lastRegularIndex = actions.lastIndex(where: { !$0.isDestructive }) {
            let destructiveGroupIndex = lastRegularIndex + 1
            dividerIndex = destructiveGroupIndex < actions.count ? destructiveGroupIndex : nil
        }

        return actions.enumerated().map { index, action in
            ActionRow(action: action, showsDivider: index == dividerIndex)
        }
    }
}

private struct ActionRow: Identifiable {
    let action: MessageAction
    let showsDivider: Bool

    var id: String { action.id }
}
