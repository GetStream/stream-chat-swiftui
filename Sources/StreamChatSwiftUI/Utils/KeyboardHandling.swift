//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

/// Publisher to read keyboard changes.
public protocol KeyboardReadable {
    var keyboardWillChangePublisher: AnyPublisher<Bool, Never> { get }
    var keyboardDidChangePublisher: AnyPublisher<Bool, Never> { get }
    var keyboardHeight: AnyPublisher<CGFloat, Never> { get }
}

/// Default implementation.
extension KeyboardReadable {
    public var keyboardWillChangePublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }

    public var keyboardDidChangePublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidShowNotification)
                .map { _ in true },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }

    public var keyboardHeight: AnyPublisher<CGFloat, Never> {
        NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardDidShowNotification)
            .map { notification in
                if let keyboardFrame: NSValue = notification
                    .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height
                    return keyboardHeight
                } else {
                    return 0
                }
            }
            .eraseToAnyPublisher()
    }
}

extension View {
    /// Dismisses the keyboard when tapping on the view.
    /// - Parameters:
    ///   - enabled: If true, tapping on the view dismisses the view, otherwise keyboard stays visible.
    ///   - onTapped: A closure which is triggered when keyboard is dismissed after tapping the view.
    func dismissKeyboardOnTap(enabled: Bool, onKeyboardDismissed: (() -> Void)? = nil) -> some View {
        modifier(HideKeyboardOnTapGesture(shouldAdd: enabled))
    }
}

/// View modifier for hiding the keyboard on tap.
public struct HideKeyboardOnTapGesture: ViewModifier {
    var shouldAdd: Bool
    var onTapped: (() -> Void)?

    public init(shouldAdd: Bool, onTapped: (() -> Void)? = nil) {
        self.shouldAdd = shouldAdd
        self.onTapped = onTapped
    }

    public func body(content: Content) -> some View {
        content
            .gesture(shouldAdd ? TapGesture().onEnded { _ in
                resignFirstResponder()
                if let onTapped = onTapped {
                    onTapped()
                }
            } : nil)
    }
}

/// Resigns first responder and hides the keyboard.
public func resignFirstResponder() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}

public let getStreamFirstResponderNotification = "io.getstream.inputView.becomeFirstResponder"

func becomeFirstResponder() {
    NotificationCenter.default.post(
        name: NSNotification.Name(getStreamFirstResponderNotification),
        object: nil
    )
}
