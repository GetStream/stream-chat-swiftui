//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SnapshotTesting
@testable import StreamChat
@testable import StreamChatCommonUI
@testable import StreamChatSwiftUI
@_exported @testable import StreamChatTestTools
@_exported import StreamSwiftTestHelpers
import SwiftUI
import XCTest

/// Base class that sets up the `StreamChat` object.
@MainActor open class StreamChatTestCase: XCTestCase {
    public static var currentUserId: String = .unique

    public var chatClient: ChatClient_Mock = {
        let client = ChatClient.mock(isLocalStorageEnabled: false)
        client.mockAuthenticationRepository.mockedCurrentUserId = currentUserId
        return client
    }()

    public var streamChat: StreamChat? {
        willSet {
            Appearance.bundle = Bundle(for: type(of: self))
        }
    }

    override open func setUp() {
        super.setUp()
        Appearance.bundle = Bundle(for: type(of: self))
        let mediaLoader = MediaLoader_Mock()
        streamChat = StreamChat(
            chatClient: chatClient,
            utils: Utils(
                mediaLoader: mediaLoader,
                composerConfig: .init(isVoiceRecordingEnabled: true)
            )
        )
        // Let StreamAsyncImage resolve mock image URLs synchronously so that
        // snapshot tests capture the loaded image rather than the empty
        // placeholder. `StreamAsyncImage` uses `.task` to load images, which
        // completes after the snapshot is taken.
        StreamAsyncImageTestHooks.syncResolver = { url, _ in
            StreamAsyncImageResult(image: mediaLoader.imageForURL(url), animatedImageData: nil)
        }
    }

    override open func tearDown() {
        StreamAsyncImageTestHooks.syncResolver = nil
        testWindow?.isHidden = true
        testWindow = nil
        super.tearDown()
    }
    
    func adjustAppearance(_ block: (inout Appearance) -> Void) {
        guard let streamChat else { return }
        var appearance = streamChat.appearance
        block(&appearance)
        streamChat.appearance = appearance
    }
    
    func setThemedNavigationBarAppearance() {
        adjustAppearance { appearance in
            appearance.colorPalette.navigationBarTintColor = .purple
            appearance.colorPalette.navigationBarTitle = .blue
            appearance.colorPalette.navigationBarSubtitle = .cyan
            appearance.colorPalette.navigationBarBackground = .yellow
            appearance.colorPalette.navigationBarGlyph = .green
        }
    }

    // MARK: - View Hosting

    private var testWindow: UIWindow?

    /// Presents a SwiftUI view in a window so lifecycle modifiers (`.onAppear`, `.onChange`) fire.
    @discardableResult
    func showView<V: View>(_ view: V) -> UIHostingController<V> {
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        testWindow = window
        hostingController.view.layoutIfNeeded()
        return hostingController
    }
}

extension StreamChatTestCase {
    func assertSnapshotWithoutVisualEffects<View: SwiftUI.View>(
        _ view: View,
        variants: [SnapshotVariant] = SnapshotVariant.all,
        device: ViewImageConfig = .iPhoneX,
        size: CGSize? = nil,
        suffix: String? = nil,
        record: Bool = false,
        line: UInt = #line,
        file: StaticString = #filePath,
        function: String = #function
    ) {
        variants.forEach { variant in
            let snapshotSize = size ?? device.size ?? defaultScreenSize
            let traits = UITraitCollection(traitsFrom: [device.traits, variant.traits])
            let image = renderedSnapshot(
                of: view.environment(\.streamLiquidGlassEffectsEnabled, false),
                size: snapshotSize,
                safeAreaInsets: device.safeArea,
                traits: traits
            )
            assertSnapshot(
                matching: image,
                as: .image(perceptualPrecision: precision),
                named: variant.snapshotName + (suffix.map { "." + $0 } ?? ""),
                record: overrideRecording ?? record,
                file: file,
                testName: function,
                line: line
            )
        }
    }

    func assertSnapshotWithoutVisualEffects<View: SwiftUI.View>(
        _ view: View,
        named name: String?,
        record: Bool = false,
        line: UInt = #line,
        file: StaticString = #filePath,
        function: String = #function
    ) {
        let displayScale = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen.scale }
            .first ?? 1
        let traits = UITraitCollection(displayScale: displayScale)
        let image = renderedSnapshot(
            of: view.environment(\.streamLiquidGlassEffectsEnabled, false),
            size: defaultScreenSize,
            safeAreaInsets: .zero,
            traits: traits
        )
        assertSnapshot(
            matching: image,
            as: .image(perceptualPrecision: precision),
            named: name,
            record: overrideRecording ?? record,
            file: file,
            testName: function,
            line: line
        )
    }

    private func renderedSnapshot<View: SwiftUI.View>(
        of view: View,
        size: CGSize,
        safeAreaInsets: UIEdgeInsets,
        traits: UITraitCollection
    ) -> UIImage {
        testWindow?.isHidden = true
        testWindow = nil

        let frame = CGRect(origin: .zero, size: size)
        let window: SnapshotWindow
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            window = SnapshotWindow(windowScene: windowScene, frame: frame, safeAreaInsets: safeAreaInsets)
        } else {
            window = SnapshotWindow(frame: frame, safeAreaInsets: safeAreaInsets)
        }
        defer {
            window.isHidden = true
            testWindow = nil
        }

        let hostingController = UIHostingController(rootView: view)
        let container = UIViewController()
        container.view.backgroundColor = .clear
        container.view.frame = frame
        container.addChild(hostingController)
        hostingController.view.frame = container.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.view.addSubview(hostingController.view)
        container.setOverrideTraitCollection(traits, forChild: hostingController)
        hostingController.didMove(toParent: container)

        window.rootViewController = container
        window.makeKeyAndVisible()
        testWindow = window

        container.beginAppearanceTransition(true, animated: false)
        container.endAppearanceTransition()
        container.view.setNeedsLayout()
        container.view.layoutIfNeeded()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        container.view.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat(for: traits)
        let renderer = UIGraphicsImageRenderer(bounds: frame, format: format)
        return renderer.image { context in
            if !window.drawHierarchy(in: frame, afterScreenUpdates: false) {
                window.layer.render(in: context.cgContext)
            }
        }
    }
}

private final class SnapshotWindow: UIWindow {
    private let configuredSafeAreaInsets: UIEdgeInsets

    init(frame: CGRect, safeAreaInsets: UIEdgeInsets) {
        configuredSafeAreaInsets = safeAreaInsets
        super.init(frame: frame)
    }

    init(windowScene: UIWindowScene, frame: CGRect, safeAreaInsets: UIEdgeInsets) {
        configuredSafeAreaInsets = safeAreaInsets
        super.init(windowScene: windowScene)
        self.frame = frame
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var safeAreaInsets: UIEdgeInsets {
        configuredSafeAreaInsets
    }
}

// Forces the solid primary button style regardless of platform,
/// preventing Liquid Glass from appearing in snapshot tests.
struct RegularToolbarConfirmActionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.buttonStyle(
            StreamButtonStyle(
                role: .primary,
                style: .solid,
                size: .medium,
                isIconOnly: true
            )
        )
    }
}

/// Test styles that mirror ``RegularStyles`` but force the solid toolbar confirm action,
/// preventing Liquid Glass from appearing in snapshot tests.
class DefaultTestStyles: Styles {
    var composerPlacement: ComposerPlacement = .docked

    func makeComposerInputViewModifier(options: ComposerInputModifierOptions) -> some ViewModifier {
        RegularInputViewModifier()
    }

    func makeComposerButtonViewModifier(options: ComposerButtonModifierOptions) -> some ViewModifier {
        RegularButtonViewModifier()
    }

    func makeScrollToBottomButtonModifier(options: ScrollToBottomButtonModifierOptions) -> some ViewModifier {
        RegularScrollToBottomButtonModifier()
    }

    func makeComposerViewModifier(options: ComposerViewModifierOptions) -> some ViewModifier {
        ComposerBackgroundRegularViewModifier()
    }

    func makeSuggestionsContainerModifier(options: SuggestionsContainerModifierOptions) -> some ViewModifier {
        SuggestionsRegularContainerModifier()
    }

    func makeToolbarConfirmActionModifier(options: ToolbarConfirmActionModifierOptions) -> some ViewModifier {
        RegularToolbarConfirmActionModifier()
    }
}

/// Test view factory that uses ``DefaultTestStyles`` to avoid Liquid Glass in snapshot tests.
class DefaultTestViewFactory: ViewFactory {
    @Injected(\.chatClient) var chatClient
    var styles = DefaultTestStyles()

    static let shared = DefaultTestViewFactory()
}
