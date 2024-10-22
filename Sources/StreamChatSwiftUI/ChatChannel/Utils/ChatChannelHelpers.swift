//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(Double.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    func flippedUpsideDown() -> some View {
        modifier(FlippedUpsideDown())
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue() ?? value
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

/// View container that allows injecting another view in its bottom right corner.
public struct BottomRightView<Content: View>: View {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                content()
            }
        }
    }
}

/// View container that allows injecting another view in its bottom left corner.
public struct BottomLeftView<Content: View>: View {
    var content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        HStack {
            VStack {
                Spacer()
                content()
            }
            Spacer()
        }
    }
}

/// Returns the top most view controller.
func topVC() -> UIViewController? {
    // TODO: Refactor ReactionsOverlayView to use a background blur, instead of a snapshot.
    /// Since the current approach is too error-prone and dependent of the app's hierarchy,

    let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

    if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            let children = topController.children
            if !children.isEmpty {
                if let splitVC = children[0] as? UISplitViewController,
                   let contentVC = splitVC.viewControllers.last {
                    topController = contentVC
                    return topController
                } else if let tabVC = children[0] as? UITabBarController,
                          let selectedVC = tabVC.selectedViewController {
                    // If the selectedVC is split view, we need to grab the content view of it
                    // other wise, the selectedVC is already the content view.
                    let selectedContentVC = selectedVC.children.first?.children.last?.children.first
                    topController = selectedContentVC ?? selectedVC
                    return topController
                }
            }
        }

        return topController
    }

    return nil
}
