## SwiftUI - Currently in Development 🏗

The SwiftUI SDK is built on top of the `StreamChat` framework and it's a SwiftUI alternative to the `StreamChatUI` SDK. It's built completely in SwiftUI, using declarative patterns, that will be familiar to developers working with SwiftUI. The SDK includes an extensive set of performant and customizable UI components which allow you to get started quickly with little to no plumbing required.

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
