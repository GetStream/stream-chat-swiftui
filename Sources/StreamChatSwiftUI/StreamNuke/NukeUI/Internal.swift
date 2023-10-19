// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import Foundation

#if !os(watchOS)

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import SwiftUI


#if os(macOS)
typealias _PlatformBaseView = NSView
typealias _PlatformImageView = NSImageView
typealias _PlatformColor = NSColor
#else
typealias _PlatformBaseView = UIView
typealias _PlatformImageView = UIImageView
typealias _PlatformColor = UIColor
#endif

extension _PlatformBaseView {
    @discardableResult
    func pinToSuperview() -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            topAnchor.constraint(equalTo: superview!.topAnchor),
            bottomAnchor.constraint(equalTo: superview!.bottomAnchor),
            leftAnchor.constraint(equalTo: superview!.leftAnchor),
            rightAnchor.constraint(equalTo: superview!.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func centerInSuperview() -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centerXAnchor.constraint(equalTo: superview!.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview!.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func layout(with position: LazyImageView.SubviewPosition) -> [NSLayoutConstraint] {
        switch position {
        case .center: return centerInSuperview()
        case .fill: return pinToSuperview()
        }
    }
}

extension CALayer {
    func animateOpacity(duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        add(animation, forKey: "imageTransition")
    }
}

#if os(macOS)
extension NSView {
    func setNeedsUpdateConstraints() {
        needsUpdateConstraints = true
    }

    func insertSubview(_ subivew: NSView, at index: Int) {
        addSubview(subivew, positioned: .below, relativeTo: subviews.first)
    }
}

extension NSColor {
    static var secondarySystemBackground: NSColor {
        .controlBackgroundColor // Close-enough, but we should define a custom color
    }
}
#endif

#if os(iOS) || os(tvOS)
extension UIView.ContentMode {
    // swiftlint:disable:next cyclomatic_complexity
    init(resizingMode: ImageResizingMode) {
        switch resizingMode {
        case .fill: self = .scaleToFill
        case .aspectFill: self = .scaleAspectFill
        case .aspectFit: self = .scaleAspectFit
        case .center: self = .center
        case .top: self = .top
        case .bottom: self = .bottom
        case .left: self = .left
        case .right: self = .right
        case .topLeft: self = .topLeft
        case .topRight: self = .topRight
        case .bottomLeft: self = .bottomLeft
        case .bottomRight: self = .bottomRight
        }
    }
}
#endif

#endif

#if os(tvOS) || os(watchOS)
import UIKit

extension UIColor {
    static var secondarySystemBackground: UIColor {
        lightGray.withAlphaComponent(0.5)
    }
}
#endif
