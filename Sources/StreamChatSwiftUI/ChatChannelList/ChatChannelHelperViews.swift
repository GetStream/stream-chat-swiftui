//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for displaying subtitle text.
public struct SubtitleText: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var text: String
    
    public var body: some View {
        Text(text)
            .lineLimit(1)
            .font(fonts.caption1)
            .foregroundColor(Color(colors.subtitleText))
    }
}

/// View container that allows injecting another view in its top right corner.
public struct TopRightView<Content: View>: View {
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
        
    public var body: some View {
        HStack {
            Spacer()
            VStack {
                content()
                Spacer()
            }
        }
    }
}

/// View representing the user's avatar.
public struct AvatarView: View {
    var avatar: UIImage
    var size: CGSize = .defaultAvatarSize
    
    public var body: some View {
        Image(uiImage: avatar)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                width: size.width,
                height: size.height
            )
            .clipShape(Circle())
    }
}

struct ChatTitleView: View {
    
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    var name: String
    
    var body: some View {
        Text(name)
            .lineLimit(1)
            .font(fonts.bodyBold)
            .foregroundColor(Color(colors.text))
    }
}

struct EmptyViewModifier: ViewModifier {
    
    public func body(content: Content) -> some View {
        content
    }
}

extension CGSize {
    /// Default size of the avatar used in the channel list.
    public static var defaultAvatarSize: CGSize = CGSize(width: 48, height: 48)
}

/// Provides access to the the app's tab bar (if present).
struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
        UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<TabBarAccessor>
    ) {}

    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = tabBarController {
                callback(tabBar.tabBar)
            }
        }
    }
}

var isIphone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}
