---
title: SwiftUI Overview
slug: /swiftui
---

The SwiftUI SDK is built on top of the `StreamChat` framework and it's a SwfitUI alternative to the `StreamChatUI` SDK. It's built completely in SwiftUI, using declarative patterns, that will be familiar to developers working with SwiftUI. The SDK includes an extensive set of performant and customizable UI components which allow you to get started quickly with little to no plumbing required.

## Architecture

The SwiftUI SDK offers three types of components:

- Screens - Easiest to integrate, but offer small customizations, like branding and text changes.
- Stateful components - Offer more customization options and possibility to inject custom views. Also fairly simple to integrate, if the extension points are suitable for your chat use-case. These components come with view models.
- Stateless components - These are the building blocks for the other two types of components. In order to use them, you would have to provide the state and data. Using these components only make sense if you want to implement completely custom chat experience.

### Dependencies

This SDK tries to keep the list of external dependencies to a minimum, these are the dependencies currently used:

#### StreamChatSwiftUI

- [Nuke](https://github.com/kean/Nuke) for loading images
- [NukeUI](https://github.com/kean/NukeUI) for SwiftUI async image loading
- [SwiftyGif](https://github.com/kirualex/SwiftyGif) for high performance GIF rendering
- StreamChat the low-level client to Stream Chat API

#### StreamChat

- [Starscream](https://github.com/daltoniam/Starscream) to handle WebSocket connections


## Installation

To get started integrating Stream Chat in your iOS app, install the `StreamChatSwiftUI` dependency using one of the following dependency managers.

### Install with Swift Package Manager

Open your `.xcodeproj`, select the option "Add Package Dependency" in File > Swift Packages, and paste the URL: "https://github.com/getstream/stream-chat-swift".

![Screenshot shows Xcode with the Add Package Dependency dialog opened and Stream Chat iOS SDK GitHub URL in the input field](../assets/spm-00.png)

After pressing next, Xcode will look for the repository and automatically select the latest version tagged. Press next and Xcode will download the dependency.

![Screenshot shows an Xcode screen selecting a dependency version and an Xcode screen downloading that dependency](../assets/spm-01.png)

The repository contains 3 targets: StreamChat, StreamChatUI and StreamChatSwiftUI. If you'll use the UI components, select one of StreamChatUI or StreamChatSwiftUI. They both provide the same functionalities, the only difference is the underlying iOS technology (SwiftUI vs. UIKit). If you don't need the UI components, select just StreamChat.

![Screenshot shows an Xcode screen with dependency targets to be selected](../assets/spm-02.png)

After you press finish, it's done!

:::caution
Because StreamChat SDKs have to be distributed with its resources, the minimal Swift version requirement for this installation method is 5.3.
:::

To stay up-to-date with our updates and get a detailed breakdown of what's new, subscribe to the releases of [getstream/stream-chat-swift](https://github.com/GetStream/stream-chat-swift/releases) by clicking the "watch" button. You can further tweak your watch preferences and subscribe only to the release events.
