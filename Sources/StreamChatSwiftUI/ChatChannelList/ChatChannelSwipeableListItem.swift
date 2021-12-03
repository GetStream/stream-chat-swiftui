//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// Chat channel cell that is swipeable.
public struct ChatChannelSwipeableListItem<ChannelDestination: View>: View {
    @Injected(\.colors) private var colors
    
    @State private var offsetX: CGFloat = 0
    @State private var openSideLock: SwipeDirection?
    
    @GestureState private var offset: CGSize = .zero
    
    @Binding var currentChannelId: String?
    
    private let itemWidth: CGFloat = 60
    private var menuWidth: CGFloat {
        itemWidth * 2 + 8
    }

    private var buttonWidth: CGFloat {
        let width = (offsetX.magnitude + addWidthMargin) * (itemWidth / menuWidth)
        return width
    }
    
    /// minimum horizontal translation value necessary to open the side menu
    private let openTriggerValue: CGFloat = 60
    /// An additional value to add to the open menu width. This is useful if the cell has rounded corners.
    private let addWidthMargin: CGFloat = 5
    
    private var channel: ChatChannel
    private var channelName: String
    private var avatar: UIImage
    private var onlineIndicatorShown: Bool
    @Binding private var selectedChannel: ChatChannel?
    private var channelDestination: (ChatChannel) -> ChannelDestination
    private var disabled = false
    private var onItemTap: (ChatChannel) -> Void
    private var onDelete: (ChatChannel) -> Void
    private var onMoreTapped: (ChatChannel) -> Void
    
    internal init(
        currentChannelId: Binding<String?>,
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool = false,
        selectedChannel: Binding<ChatChannel?>,
        channelDestination: @escaping (ChatChannel) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        onDelete: @escaping (ChatChannel) -> Void,
        onMoreTapped: @escaping (ChatChannel) -> Void
    ) {
        self.channel = channel
        self.channelName = channelName
        self.avatar = avatar
        self.onlineIndicatorShown = onlineIndicatorShown
        self.channelDestination = channelDestination
        self.disabled = disabled
        self.onItemTap = onItemTap
        self.onDelete = onDelete
        self.onMoreTapped = onMoreTapped
        _currentChannelId = currentChannelId
        _selectedChannel = selectedChannel
    }
    
    public var body: some View {
        ZStack {
            if self.offsetX != 0 {
                swipeActionsView
            }
            
            ChatChannelNavigatableListItem(
                channel: channel,
                channelName: channelName,
                avatar: avatar,
                onlineIndicatorShown: onlineIndicatorShown,
                disabled: disabled,
                selectedChannel: $selectedChannel,
                channelDestination: channelDestination,
                onItemTap: onItemTap
            )
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
        .id("\(channel.id)-swipeable")
    }
    
    private func dragChanged(to value: CGFloat) {
        let horizontalTranslation = value
         
        if horizontalTranslation > 0 && openSideLock == nil {
            // prevent swiping to left.
            return
        }

        if let openSideLock = self.openSideLock {
            offsetX = menuWidth * openSideLock.sideFactor + horizontalTranslation
            return
        }
                 
        if horizontalTranslation < 0 {
            currentChannelId = channel.id
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
            currentChannelId = nil
        }
    }

    private func dragEnded() {
        if offsetX == 0 {
            currentChannelId = nil
            openSideLock = nil
        } else if offsetX > 0 {
            setOffsetX(value: 0)
        } else {
            if offsetX.magnitude < openTriggerValue ||
                offsetX > -menuWidth * 0.8 {
                setOffsetX(value: 0)
            } else {
                lockSideMenu(side: .trailing)
            }
        }
    }
    
    private func lockSideMenu(side: SwipeDirection) {
        setOffsetX(value: side.sideFactor * menuWidth)
        openSideLock = side
    }
    
    private var swipeActionsView: some View {
        HStack {
            Spacer()
            ZStack {
                HStack(spacing: 0) {
                    ActionItemButton(imageName: "ellipsis", action: {
                        withAnimation {
                            onMoreTapped(channel)
                        }
                    })
                        .frame(width: buttonWidth)
                        .foregroundColor(Color(colors.text))
                        .background(Color(colors.background1))
                        
                    ActionItemButton(imageName: "trash", action: {
                        withAnimation {
                            onDelete(channel)
                        }
                    })
                        .frame(width: buttonWidth)
                        .foregroundColor(Color(colors.textInverted))
                        .background(Color(colors.alert))
                }
            }
            .opacity(self.offsetX < -5 ? 1 : 0)
        }
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
