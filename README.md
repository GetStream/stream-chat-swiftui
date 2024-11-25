<p align="center">
  <img src="ReadmeAssets/iOS_Chat_Messaging.png"/>
</p>

<p align="center">
  <a href="https://sonarcloud.io/summary/new_code?id=GetStream_stream-chat-swiftui"><img src="https://sonarcloud.io/api/project_badges/measure?project=GetStream_stream-chat-swiftui&metric=coverage" /></a>

  <img id="stream-chat-swiftui-label" alt="StreamChatSwiftUI" src="https://img.shields.io/badge/StreamChatSwiftUI-8.09%20MB-blue"/>
</p>

## SwiftUI StreamChat SDK

The SwiftUI SDK is built on top of the [StreamChat](https://getstream.io/chat/docs/ios-swift/?language=swift) framework and it's a SwiftUI alternative to the [StreamChatUI](https://getstream.io/chat/docs/sdk/ios/) SDK. It's built completely in SwiftUI, using declarative patterns, that will be familiar to developers working with SwiftUI. The SDK includes an extensive set of performant and customizable UI components which allow you to get started quickly with little to no plumbing required.

The complete documentation and capabilities of the SwiftUI SDK can be found [here](https://getstream.io/chat/docs/sdk/ios/swiftui/) and you may find our [SwiftUI Chat App tutorial](https://getstream.io/tutorials/swiftui-chat/) helpful as well.

## Main Features

- **Channel list:** Browse channels and perform actions on them.
- **Message list:** Fast message list that renders many different types of messages.
- **Message Composer:** Powerful and customizable message composer, extendable with your own custom attachments.
- **Message reactions:** Ready made reactions support, easily configurable depending on your use-cases.
- **Offline support:** Browse channels and send messages while offline.
- **Highly customizable components:** The components are designed in a way that you can easily customize or completely swap existing views with your own implementation.

## Main Principles

- **Progressive disclosure:** The SDK can be used easily with very minimal knowledge of it. As you become more familiar with it, you can dig deeper and start customizing it on all levels.
- **Familiar behavior**: The UI elements are good platform citizens and behave like native elements; they respect `tintColor`, paddings, light/dark mode, dynamic font sizes, etc.
- **Swift native API:** Uses Swift's powerful language features to make the SDK usage easy and type-safe.
- **Uses `SwiftUI` patterns and paradigms:** The API follows the declarative nature and patterns of SwiftUI. It makes integration with your existing SwiftUI code easy and familiar.
- **Fully open-source implementation:** You have access to the complete source code of the SDK here on GitHub.

## Architecture

The SwiftUI SDK offers three types of components:

- Screens - Easiest to integrate, but offer small customizations, like branding and text changes.
- Stateful components - Offer more customization options and possibility to inject custom views. Also fairly simple to integrate, if the extension points are suitable for your chat use-case. These components come with view models.
- Stateless components - These are the building blocks for the other two types of components. In order to use them, you would have to provide the state and data. Using these components only make sense if you want to implement completely custom chat experience.

## Free for Makers

Stream is free for most side and hobby projects. You can use Stream Chat for free if you have less than five team members and no more than $10,000 in monthly revenue.

---

## We are hiring
We've recently closed a [\$38 million Series B funding round](https://techcrunch.com/2021/03/04/stream-raises-38m-as-its-chat-and-activity-feed-apis-power-communications-for-1b-users/) and we keep actively growing.
Our APIs are used by more than a billion end-users, and you'll have a chance to make a huge impact on the product within a team of the strongest engineers all over the world.
Check out our current openings and apply via [Stream's website](https://getstream.io/team/#jobs).

## Quick Overview

### Channel List

<table>
  <tr>
    <th width="50%">Features</th>
    <th width="30%">Preview</th>
  </tr>
  <tr>
    <td> A list of channels matching provided query </td>
    <th rowspan="9"><img src="ReadmeAssets/ChannelListPreview.gif?raw=true" width="80%" /></th>
  </tr>
   <tr> <td> Channel name and image based on the channel members or custom data</td> </tr>
  <tr> <td> Unread messages indicator </td> </tr>
  <tr> <td> Preview of the last message </td> </tr>
  <tr> <td> Online indicator for avatars </td> </tr>
  <tr> <td> Create new channel and start right away </td> </tr>
  <tr> <td> Customizable channel actions on swipe </td> </tr>
  <tr> <td> Typing and read indicators </td> </tr>
  <tr><td> </td> </tr>
  </tr>
</table>

### Message List

<table>
  <tr>
    <th width="50%">Features</th>
    <th width="30%">Preview</th>
  </tr>
  <tr>
    <td> A list of messages in a channel </td>
    <th rowspan="12"><img src="ReadmeAssets/MessageListPreview.gif?raw=true" width="80%" /></th>
  </tr>
  <tr> <td> Photo attachments </td> </tr>
  <tr> <td> Giphy attachments </td> </tr>
  <tr> <td> Video attachments </td> </tr>
  <tr> <td> Link previews </td> </tr>
  <tr> <td> File previews </td> </tr>
  <tr> <td> Custom attachments </td> </tr>
  <tr> <td> Message reactions </td> </tr>
  <tr> <td> Message grouping based on the send time </td> </tr>
  <tr> <td> Thread and inline replies </td> </tr>
  <tr> <td> Typing and read indicators </td> </tr>
  <tr><td> </td> </tr>
  </tr>
</table>

---

### Message Composer

<table>
  <tr>
    <th width="50%">Features</th>
    <th width="30%">Preview</th>
  </tr>
  <tr>
    <td> Support for multiline text, expands and shrinks as needed </td>
    <th rowspan="8"><img src="ReadmeAssets/Message_Composer_Bezels.png?raw=true" width="80%" /></th>
  </tr>
  <tr> <td> Image, video and file attachments </td> </tr>
  <tr> <td> Camera integration </td> </tr>
  <tr> <td> Custom attachments </td> </tr>
  <tr> <td> Mentions </td> </tr>
  <tr> <td> Instant commands (e.g. giphy) </td> </tr>
  <tr> <td> Custom commands </td> </tr>
  <tr><td> </td> </tr>
  </tr>
</table>

---
