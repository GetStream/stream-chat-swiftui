//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for displaying subtitle text.
public struct SubtitleText: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var text: String
    var color: Color?

    public init(text: String, color: Color? = nil) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .lineLimit(1)
            .font(fonts.subheadline)
            .foregroundColor(color ?? Color(colors.textSecondary))
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

public struct ChatTitleView: View {
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors

    var name: String

    public init(name: String) {
        self.name = name
    }

    public var body: some View {
        Text(name)
            .lineLimit(1)
            .font(fonts.headline)
            .foregroundColor(Color(colors.textPrimary))
            .accessibilityIdentifier("ChatTitleView")
    }
}

public struct EmptyViewModifier: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
    }
}

extension CGSize {
    /// Default size of the avatar used in the channel list.
    public nonisolated(unsafe) static var defaultAvatarSize: CGSize = CGSize(width: 48, height: 48)
}

/// Provides access to the the app's tab bar (if present) and updates its visibility.
///
/// Hiding the tab bar is applied right away, while showing it happens only when the
/// containing screen is actually visible. During an interactive back swipe the pushed
/// screen is still on screen, so an earlier update would place the tab bar on top of it.
struct TabBarAccessor: UIViewControllerRepresentable {
    /// Whether the tab bar should be hidden. Its visibility is not managed when nil.
    var isTabBarHidden: Bool?
    /// Called when the tab bar is found in the view hierarchy.
    var callback: ((UITabBar) -> Void)?

    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.callback = callback
        uiViewController.isTabBarHidden = isTabBarHidden
    }

    class ViewController: UIViewController {
        var callback: ((UITabBar) -> Void)?

        var isTabBarHidden: Bool? {
            didSet { updateTabBarVisibility() }
        }

        private var isScreenVisible = false

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = tabBarController?.tabBar {
                callback?(tabBar)
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            isScreenVisible = true
            updateTabBarVisibility()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            isScreenVisible = false
        }

        private func updateTabBarVisibility() {
            guard let isTabBarHidden, let tabBar = tabBarController?.tabBar else { return }
            guard isTabBarHidden || isScreenVisible else { return }
            tabBar.isHidden = isTabBarHidden
        }
    }
}

var isIphone: Bool {
    UITraitCollection.current.userInterfaceIdiom == .phone
}

var isIPad: Bool {
    UITraitCollection.current.userInterfaceIdiom == .pad
}
