//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import SwiftUI

struct TopAlignedMessageListScrollViewModifier: ViewModifier {
    var isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, *) {
            content
                .defaultScrollAnchor(isEnabled ? .top : nil, for: .initialOffset)
                .defaultScrollAnchor(isEnabled ? .top : nil, for: .sizeChanges)
                .defaultScrollAnchor(isEnabled ? .bottom : nil, for: .alignment)
        } else {
            content
        }
    }
}

struct LegacyTopAlignedMessageListScrollViewModifier: ViewModifier {
    var isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 18, *) {
            content
        } else {
            content.background(
                LegacyTopAlignedMessageListScrollViewBridge(isEnabled: isEnabled)
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            )
        }
        #else
        content
        #endif
    }
}

#if os(iOS)
import UIKit

private struct LegacyTopAlignedMessageListScrollViewBridge: UIViewRepresentable {
    var isEnabled: Bool

    func makeUIView(context: Context) -> LegacyTopAlignedMessageListScrollViewObserver {
        let view = LegacyTopAlignedMessageListScrollViewObserver()
        view.isEnabled = isEnabled
        return view
    }

    func updateUIView(_ uiView: LegacyTopAlignedMessageListScrollViewObserver, context: Context) {
        uiView.isEnabled = isEnabled
    }

    static func dismantleUIView(_ uiView: LegacyTopAlignedMessageListScrollViewObserver, coordinator: ()) {
        uiView.isEnabled = false
    }
}

private final class LegacyTopAlignedMessageListScrollViewObserver: UIView {
    var isEnabled = false {
        didSet {
            guard isEnabled != oldValue else { return }
            updateAlignment()
        }
    }

    private weak var scrollView: UIScrollView?
    private var baselineInsets: UIEdgeInsets?
    private var boundsObservation: NSKeyValueObservation?
    private var contentSizeObservation: NSKeyValueObservation?
    private var isUpdating = false
    private var contentPreviouslyFit: Bool?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        bindScrollViewIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bindScrollViewIfNeeded()
        updateAlignment()
    }

    private func bindScrollViewIfNeeded() {
        guard let scrollView = findScrollView(), self.scrollView !== scrollView else { return }

        restoreBaselineInset()
        self.scrollView = scrollView
        baselineInsets = scrollView.contentInset
        boundsObservation = scrollView.observe(\.bounds, options: [.old, .new]) { [weak self] _, change in
            guard change.oldValue?.size != change.newValue?.size else { return }
            self?.updateAlignment()
        }
        contentSizeObservation = scrollView.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            self?.updateAlignment()
        }
        updateAlignment()
    }

    private func updateAlignment() {
        guard !isUpdating, let scrollView, let baselineInsets else { return }
        guard isEnabled else {
            restoreBaselineInset()
            return
        }
        guard scrollView.bounds.height > 0 else { return }

        let availableHeight = max(
            0,
            scrollView.bounds.height - baselineInsets.top - baselineInsets.bottom
        )
        let contentFits = scrollView.contentSize.height <= availableHeight + 0.5
        let spacerHeight = contentFits ? max(0, availableHeight - scrollView.contentSize.height) : 0
        let targetTopInset = baselineInsets.top + spacerHeight
        let wasPinned = abs(scrollView.contentOffset.y + scrollView.contentInset.top) <= 1

        isUpdating = true
        UIView.performWithoutAnimation {
            if abs(scrollView.contentInset.top - targetTopInset) > 0.5 {
                var insets = scrollView.contentInset
                insets.top = targetTopInset
                scrollView.contentInset = insets
            }
            if !scrollView.isDragging,
               !scrollView.isDecelerating,
               contentFits || contentPreviouslyFit == true || wasPinned {
                let targetOffset = CGPoint(x: scrollView.contentOffset.x, y: -targetTopInset)
                if abs(scrollView.contentOffset.y - targetOffset.y) > 0.5 {
                    scrollView.setContentOffset(targetOffset, animated: false)
                }
            }
        }
        isUpdating = false
        contentPreviouslyFit = contentFits
    }

    private func restoreBaselineInset() {
        guard !isUpdating, let scrollView, let baselineInsets else { return }
        guard abs(scrollView.contentInset.top - baselineInsets.top) > 0.5 else { return }

        isUpdating = true
        let wasPinned = abs(scrollView.contentOffset.y + scrollView.contentInset.top) <= 1
        var insets = scrollView.contentInset
        insets.top = baselineInsets.top
        scrollView.contentInset = insets
        if wasPinned {
            scrollView.setContentOffset(
                CGPoint(x: scrollView.contentOffset.x, y: -baselineInsets.top),
                animated: false
            )
        }
        isUpdating = false
    }

    private func findScrollView() -> UIScrollView? {
        var ancestor = superview
        while let current = ancestor {
            if let scrollView = current as? UIScrollView {
                return scrollView
            }
            ancestor = current.superview
        }
        return nil
    }
}
#endif
