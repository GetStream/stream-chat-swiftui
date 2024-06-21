//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import SwiftUI

extension View {
    /// Presents an alert banner with a title at the top of the view.
    ///
    /// - Parameters:
    ///   - title: A text string used as the title of the alert banner.
    ///   - isPresented: A binding to a Boolean value that determines whether to present the alert banner.
    ///   - action: An action which is added to the view through refreshable view modifier.
    ///   - duration: The amount if time after which the banner is dismissed automatically.
    func alertBanner(
        _ title: String = L10n.Alert.Error.title,
        isPresented: Binding<Bool>,
        action: (() -> Void)? = nil,
        duration: TimeInterval = 3
    ) -> some View {
        modifier(
            AlertBannerViewModifier(
                title: title,
                isPresented: isPresented,
                action: action,
                duration: duration
            )
        )
    }
}

private struct AlertBannerViewModifier: ViewModifier {
    @Injected(\.colors) private var colors
    let title: String
    @Binding var isPresented: Bool
    let action: (() -> Void)?
    let duration: TimeInterval
    @State private var timer: Timer?
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            VStack {
                if isPresented {
                    Text(title)
                        .font(.body)
                        .foregroundColor(Color(colors.staticColorText))
                        .padding(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .frame(maxWidth: .infinity)
                        .background(Color(colors.textLowEmphasis))
                        .transition(.move(edge: .top))
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .clipped()
            content
        }
        .alertBannerRefreshable(action: action)
        .animation(.easeIn, value: isPresented)
        .onChange(of: isPresented) { newValue in
            guard newValue else { return }
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                isPresented = false
            }
        }
    }
}

// MARK: - Refreshable Compatibility

private struct AlertBannerActionViewModifier: ViewModifier {
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *), let action {
            content
                .refreshable { action() }
        } else {
            content
        }
    }
}

private extension View {
    func alertBannerRefreshable(action: (() -> Void)?) -> some View {
        modifier(AlertBannerActionViewModifier(action: action))
    }
}
