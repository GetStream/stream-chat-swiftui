---
title: Message List
---

## What is the message list?

The message list is the place to show a list of the messages of a specific channel.

The **default message list implementation** in the SDK follows the style of **other messaging apps** such as Apple's iMessage, Facebook Messenger, WhatsApp, Viber, and many other. In these kinds of apps, the **current sender's messages** are displayed on the **right side**, while the **other participants' messages** are displayed on the **left side**. In addition to that, there is an **avatar** of the user sending a message shown.

## Customization options

### Changing the Message List Configuration

For general customizations, the best place to start is the `MessageListConfig`. This is a configuration file that can be used in the `Utils` class that is handed to the `StreamChat` object upon initialization.

:::info
Reminder: The configuration of the `StreamChat` object is recommended to be happening in the `AppDelegate` file. A guide on how to do this can be found [here](../getting-started.md).
:::

You can control the display of the helper views around the message (date indicators, avatars) and paddings, via the `MessageListConfig`'s properties `MessageDisplayOptions` and `MessagePaddings`. The `MessageListConfig` is part of the `Utils` class in `StreamChat`. Here's an example on how to hide the date indicators and avatars, while also increasing the horizontal padding.

```swift
let messageDisplayOptions = MessageDisplayOptions(showAvatars: false, showMessageDate: false)
let messagePaddings = MessagePaddings(horizontal: 16)
let messageListConfig = MessageListConfig(
    messageListType: .messaging,
    typingIndicatorPlacement: .navigationBar,
    groupMessages: true,
    messageDisplayOptions: messageDisplayOptions,
    messagePaddings: messagePaddings
)
let utils = Utils(messageListConfig: messageListConfig)
streamChat = StreamChat(chatClient: chatClient, utils: utils)
```

Other config options you can enable or disable via the `MessageListConfig` are:

- `messagePopoverEnabled` - the default value is true. If set to false, it will disable the message popover.
- `doubleTapOverlayEnabled` - the default value is false. If set to true, you can show the message popover also with double tap.
- `becomesFirstResponderOnOpen` - the default value is false. If set to true, the channel will open the keyboard on view appearance.

With the `MessageDisplayOptions`, you can also customize the transitions applied to the message views. The default message view transition in the SDK is `identity`. You can use the other default ones, such as `scale`, `opacity` and `slide`, or you can create your own custom transitions. Here's an example how to do this:

```swift
var customTransition: AnyTransition {
    .scale.combined(with:
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    )
}

let messageDisplayOptions = MessageDisplayOptions(
    currentUserMessageTransition: customTransition,
    otherUserMessageTransition: customTransition
)
```

For link attachments, you can control the link text attributes (font, font weight, color) based on the message. Here's an example of how to change the link color based on the message sender, with the `messageLinkDisplayResolver`:

```swift
let messageDisplayOptions = MessageDisplayOptions(messageLinkDisplayResolver: { message in
    let color = message.isSentByCurrentUser ? UIColor.red : UIColor.green

    return [
        NSAttributedString.Key.foregroundColor: color
    ]
})
let messageListConfig = MessageListConfig(messageDisplayOptions: messageDisplayOptions)
let utils = Utils(messageListConfig: messageListConfig)

let streamChat = StreamChat(chatClient: chatClient, utils: utils)
```

### Date Indicators

### Background

### Custom Modifier

### Grouping Messages

### System Messages

## No Messages View
