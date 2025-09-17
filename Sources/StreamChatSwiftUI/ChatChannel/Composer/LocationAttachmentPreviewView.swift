//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// Preview view for location attachments in the composer.
public struct LocationAttachmentPreviewView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let location: LocationAttachmentPayload
    let onDiscard: () -> Void
    
    public init(location: LocationAttachmentPayload, onDiscard: @escaping () -> Void) {
        self.location = location
        self.onDiscard = onDiscard
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Location icon
            Image(systemName: "location.fill")
                .font(.title2)
                .foregroundColor(Color(colors.tintColor))
                .frame(width: 24, height: 24)
            
            // Location details
            VStack(alignment: .leading, spacing: 2) {
                if let name = location.name {
                    Text(name)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.text))
                        .lineLimit(1)
                }
                
                if let address = location.address {
                    Text(address)
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                        .lineLimit(2)
                }
                
                Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                    .font(fonts.caption)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
            
            Spacer()
            
            // Discard button
            Button(action: onDiscard) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(Color(colors.textLowEmphasis))
            }
        }
        .padding(12)
        .background(Color(colors.background))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(colors.innerBorder), lineWidth: 1)
        )
    }
}

/// View for displaying multiple location attachments in the composer.
public struct LocationAttachmentsPreviewView: View {
    let addedCustomAttachments: [CustomAttachment]
    let onCustomAttachmentTap: (CustomAttachment) -> Void
    
    public init(
        addedCustomAttachments: [CustomAttachment],
        onCustomAttachmentTap: @escaping (CustomAttachment) -> Void
    ) {
        self.addedCustomAttachments = addedCustomAttachments
        self.onCustomAttachmentTap = onCustomAttachmentTap
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            ForEach(addedCustomAttachments) { attachment in
                if let locationPayload = attachment.content.payload as? LocationAttachmentPayload {
                    LocationAttachmentPreviewView(
                        location: locationPayload,
                        onDiscard: {
                            onCustomAttachmentTap(attachment)
                        }
                    )
                }
            }
        }
    }
}
