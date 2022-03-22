---
title: Message inline replies
---

## Inline Replies Overview

The SwiftUI SDK has support for inline message replies. These replies are invoked either by swiping left on a message, or via long pressing a message and selecting the "Reply" action. When a message is quoted, it appears in the message composer, as an indication which message the user is replying to.

## Customizing the Quoted Message

When a message appears as quoted in the composer, you can customize both the header and the quoted message with the user avatar. The header is at the top of the composer, and by default it has a title and a button to remove the quoted message from the composer. To swap this view with your own implementation, you need to implement the `makeQuotedMessageHeaderView` method in the `ViewFactory`, which passes a binding of the quoted chat message.

```swift
public func makeQuotedMessageHeaderView(
        quotedMessage: Binding<ChatMessage?>
) -> some View {
    CustomQuotedMessageHeaderView(quotedMessage: quotedMessage)
}
```

Another customization that can be done is to swap the preview of the message shown in the composer. The default implementation is able to present several different attachments, such as text, image, video, gifs, links and files. The UI consists of small image and either the message text (if present), or a description for the attachment.

In order to swap this UI, you need to implement the `makeQuotedMessageComposerView` method in the `ViewFactory`. The method passes the quoted message as a parameter.

```swift
public func makeQuotedMessageComposerView(
        quotedMessage: ChatMessage
) -> some View {
    QuotedMessageViewContainer(
        quotedMessage: quotedMessage,
        fillAvailableSpace: true,
        forceLeftToRight: true,
        scrolledId: .constant(nil)
    )
}
```

If you only want to customize the message avatar, without changing the whole quoted message composer view, you can implement the `makeQuotedMessageAvatarView`. This method is called with `UserDisplayInfo` that you can use to populate the avatar's data, as well as the required `size` for this view. Note, if you don't set this size in your implementation, the view might not fit in the quoted message composer view.

```swift
func makeQuotedMessageAvatarView(
    for userDisplayInfo: UserDisplayInfo,
    size: CGSize
) -> some View {
    MessageAvatarView(avatarURL: userDisplayInfo.imageURL, size: size)
}
```

Finally, we need to inject the your `CustomFactory` in our view hierarchy.

```swift
var body: some Scene {
    WindowGroup {
        ChatChannelListView(viewFactory: CustomFactory.shared)
    }
}
```