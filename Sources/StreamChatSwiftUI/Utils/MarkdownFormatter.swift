//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

/// Converts markdown string to AttributedString with styling attributes.
@available(iOS 15, *)
final class MarkdownFormatter {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    func format(
        _ string: String,
        attributes: AttributeContainer,
        layoutDirection: LayoutDirection
    ) -> AttributedString {
        do {
            return try MarkdownParser.style(
                markdown: string,
                options: .init(layoutDirectionLeftToRight: layoutDirection == .leftToRight),
                attributes: attributes,
                inlinePresentationIntentAttributes: inlinePresentationIntentAttributes(for:),
                presentationIntentAttributes: presentationIntentAttributes(for:in:)
            )
        } catch {
            log.debug("Failed to parse markdown with error \(error.localizedDescription)")
            return AttributedString(string, attributes: attributes)
        }
    }
    
    // MARK: - Styling Attributes
    
    private func inlinePresentationIntentAttributes(
        for inlinePresentationIntent: InlinePresentationIntent
    ) -> AttributeContainer? {
        nil // use default attributes
    }
    
    private func presentationIntentAttributes(
        for presentationKind: PresentationIntent.Kind,
        in presentationIntent: PresentationIntent
    ) -> AttributeContainer? {
        switch presentationKind {
        case .blockQuote:
            return AttributeContainer()
                .foregroundColor(Color(colors.subtitleText))
        case .codeBlock:
            return AttributeContainer()
                .font(fonts.body.monospaced())
        case let .header(level):
            let font: Font = {
                switch level {
                case 1:
                    return fonts.title
                case 2:
                    return fonts.title2
                case 3:
                    return fonts.title3
                case 4:
                    return fonts.headline
                case 5:
                    return fonts.subheadline
                default:
                    return fonts.subheadline
                }
            }()
            let foregroundColor: Color? = level >= 6 ? Color(colors.subtitleText) : nil
            if let foregroundColor {
                return AttributeContainer()
                    .font(font)
                    .foregroundColor(foregroundColor)
            } else {
                return AttributeContainer()
                    .font(font)
            }
        default:
            return nil
        }
    }
}
