//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel cell that is swipeable.
public struct ChatChannelSwipeableListItem<Factory: ViewFactory, ChannelListItem: View>: View {
    @Injected(\.colors) private var colors

    @State private var offsetX: CGFloat = 0
    @State private var openSideLock: SwipeDirection?

    @GestureState private var offset: CGSize = .zero

    @Binding var swipedChannelId: String?

    private let numberOfTrailingItems: Int

    private let itemWidth: CGFloat
    private var menuWidth: CGFloat {
        itemWidth * CGFloat(numberOfTrailingItems) + 8
    }

    private var buttonWidth: CGFloat {
        let totalWidth = width(for: openSideLock ?? .trailing)
        let width = (offsetX.magnitude + addWidthMargin) * (itemWidth / totalWidth)
        return width
    }

    /// minimum horizontal translation value necessary to open the side menu
    private let openTriggerValue: CGFloat = 60
    private let maxTriggerValue: CGFloat = 300
    /// An additional value to add to the open menu width. This is useful if the cell has rounded corners.
    private let addWidthMargin: CGFloat = 5

    private var factory: Factory
    private var channelListItem: ChannelListItem
    private var channel: ChatChannel
    private var trailingRightButtonTapped: (ChatChannel) -> Void
    private var trailingLeftButtonTapped: (ChatChannel) -> Void
    private var leadingButtonTapped: (ChatChannel) -> Void

    public init(
        factory: Factory,
        channelListItem: ChannelListItem,
        swipedChannelId: Binding<String?>,
        channel: ChatChannel,
        numberOfTrailingItems: Int = 2,
        widthOfTrailingItem: CGFloat = 60,
        trailingRightButtonTapped: @escaping (ChatChannel) -> Void,
        trailingLeftButtonTapped: @escaping (ChatChannel) -> Void,
        leadingSwipeButtonTapped: @escaping (ChatChannel) -> Void
    ) {
        self.factory = factory
        self.channelListItem = channelListItem
        self.channel = channel
        itemWidth = widthOfTrailingItem
        self.numberOfTrailingItems = numberOfTrailingItems
        self.trailingRightButtonTapped = trailingRightButtonTapped
        self.trailingLeftButtonTapped = trailingLeftButtonTapped
        leadingButtonTapped = leadingSwipeButtonTapped
        _swipedChannelId = swipedChannelId
    }

    public var body: some View {
        ZStack {
            if self.offsetX < 0, showTrailingSwipeActions {
                trailingSwipeActions
            } else if self.offsetX > 0, showLeadingSwipeActions {
                leadingSwipeActions
            }

            channelListItem
                .offset(x: self.offsetX)
                .simultaneousGesture(
                    DragGesture(
                        minimumDistance: 10,
                        coordinateSpace: .local
                    )
                    .updating($offset) { (value, gestureState, _) in
                        // Using updating since onEnded is not called if the gesture is canceled.
                        let diff = CGSize(
                            width: value.location.x - value.startLocation.x,
                            height: value.location.y - value.startLocation.y
                        )

                        if diff == .zero {
                            gestureState = .zero
                        } else {
                            gestureState = value.translation
                        }
                    }
                )
        }
        .onChange(of: offset, perform: { _ in
            if offset == .zero {
                // gesture ended or cancelled
                dragEnded()
            } else {
                dragChanged(to: offset.width)
            }
        })
        .onChange(of: swipedChannelId, perform: { _ in
            if swipedChannelId != channel.id && offsetX != 0 {
                setOffsetX(value: 0)
            }
        })
        .id("\(channel.id)-swipeable")
        .accessibilityIdentifier("ChatChannelSwipeableListItem")
    }

    private var trailingSwipeActions: some View {
        factory.makeTrailingSwipeActionsView(
            channel: channel,
            offsetX: offsetX,
            buttonWidth: buttonWidth,
            swipedChannelId: $swipedChannelId,
            leftButtonTapped: trailingLeftButtonTapped,
            rightButtonTapped: trailingRightButtonTapped
        )
    }

    private var showTrailingSwipeActions: Bool {
        !(trailingSwipeActions is EmptyView)
    }

    private var leadingSwipeActions: some View {
        factory.makeLeadingSwipeActionsView(
            channel: channel,
            offsetX: offsetX,
            buttonWidth: buttonWidth,
            swipedChannelId: $swipedChannelId,
            buttonTapped: leadingButtonTapped
        )
    }

    private var showLeadingSwipeActions: Bool {
        !(leadingSwipeActions is EmptyView)
    }

    private func dragChanged(to value: CGFloat) {
        let horizontalTranslation = value

        if abs(horizontalTranslation) > maxTriggerValue { return }

        if horizontalTranslation > 0 && openSideLock == nil && !showLeadingSwipeActions {
            // prevent swiping to left, if not configured.
            return
        }

        if horizontalTranslation < 0 && openSideLock == nil && !showTrailingSwipeActions {
            // prevent swiping to right, if not configured.
            return
        }

        if let openSideLock = self.openSideLock {
            offsetX = width(for: openSideLock) * openSideLock.sideFactor + horizontalTranslation
            return
        }

        if horizontalTranslation != 0 {
            if swipedChannelId != channel.id {
                swipedChannelId = channel.id
            }
            offsetX = horizontalTranslation
        } else {
            offsetX = 0
        }
    }

    private func setOffsetX(value: CGFloat) {
        withAnimation {
            self.offsetX = value
        }
        if offsetX == 0 {
            openSideLock = nil
            swipedChannelId = nil
        }
    }

    private func dragEnded() {
        if offsetX == 0 {
            swipedChannelId = nil
            openSideLock = nil
        } else if offsetX > 0 && showLeadingSwipeActions {
            if offsetX.magnitude < openTriggerValue ||
                offsetX < menuWidth * 0.8 {
                setOffsetX(value: 0)
            } else {
                lockSideMenu(side: .leading)
            }
        } else if offsetX < 0 && showTrailingSwipeActions {
            if offsetX.magnitude < openTriggerValue ||
                offsetX > -menuWidth * 0.8 {
                setOffsetX(value: 0)
            } else {
                lockSideMenu(side: .trailing)
            }
        } else {
            setOffsetX(value: 0)
        }
    }

    private func lockSideMenu(side: SwipeDirection) {
        setOffsetX(value: side.sideFactor * width(for: side))
        openSideLock = side
    }

    private func width(for direction: SwipeDirection) -> CGFloat {
        direction == .leading ? itemWidth : menuWidth
    }
}

/// Enum that describes the swipe direction.
public enum SwipeDirection {
    case leading
    case trailing

    var sideFactor: CGFloat {
        switch self {
        case .leading:
            return 1
        case .trailing:
            return -1
        }
    }
}

public struct TrailingSwipeActionsView: View {

    @Injected(\.colors) private var colors

    var channel: ChatChannel
    var offsetX: CGFloat
    var buttonWidth: CGFloat
    var leftButtonTapped: (ChatChannel) -> Void
    var rightButtonTapped: (ChatChannel) -> Void

    public var body: some View {
        HStack {
            Spacer()
            ZStack {
                HStack(spacing: 0) {
                    ActionItemButton(imageName: "ellipsis", action: {
                        withAnimation {
                            leftButtonTapped(channel)
                        }
                    })
                        .frame(width: buttonWidth)
                        .foregroundColor(Color(colors.text))
                        .background(Color(colors.background1))

                    if channel.ownCapabilities.contains(.deleteChannel) {
                        ActionItemButton(imageName: "trash", action: {
                            withAnimation {
                                rightButtonTapped(channel)
                            }
                        })
                            .frame(width: buttonWidth)
                            .foregroundColor(Color(colors.textInverted))
                            .background(Color(colors.alert))
                    }
                }
            }
            .opacity(self.offsetX < -5 ? 1 : 0)
        }
        .accessibilityIdentifier("TrailingSwipeActionsView")
    }
}

public struct ActionItemButton: View {
    private var imageName: String
    private var action: () -> Void

    public init(imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Spacer()
                Image(systemName: imageName)
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
            }
        }
    }
}
