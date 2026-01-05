//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import SwiftUI

public protocol MarkdownFormatter {
    /// Formats a Markdown string into an `AttributedString`, merging Markdown styles with the provided base attributes and honoring the given layout direction.
    /// - Parameters:
    ///   - string: The Markdown-formatted source string to render.
    ///   - attributes: Base attributes applied to the entire string; Markdown-specific styling is merged on top of these defaults.
    ///   - layoutDirection: The text layout direction (left-to-right or right-to-left) used when interpreting and rendering Markdown blocks (for example, lists, block quotes, and headings).
    /// - Returns: An `AttributedString` containing the rendered Markdown with the resolved attributes.
    @available(iOS 15, *)
    func format(
        _ string: String,
        attributes: AttributeContainer,
        layoutDirection: LayoutDirection
    ) -> AttributedString
}

/// Converts markdown string to AttributedString with styling attributes.
open class DefaultMarkdownFormatter: MarkdownFormatter {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    private let markdownParser: MarkdownParser
    
    public init() {
        markdownParser = MarkdownParser()
    }
        
    @available(iOS 15, *)
    open func format(
        _ string: String,
        attributes: AttributeContainer,
        layoutDirection: LayoutDirection
    ) -> AttributedString {
        do {
            return try markdownParser.style(
                markdown: string,
                options: MarkdownParser.ParsingOptions(layoutDirectionLeftToRight: layoutDirection == .leftToRight),
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
    
    @available(iOS 15, *)
    private func inlinePresentationIntentAttributes(
        for inlinePresentationIntent: InlinePresentationIntent
    ) -> AttributeContainer? {
        nil // use default attributes
    }
    
    @available(iOS 15, *)
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
                    return fonts.footnote
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
