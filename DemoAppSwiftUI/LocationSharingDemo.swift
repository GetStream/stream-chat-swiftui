//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatSwiftUI
import SwiftUI

/// Demo view showing how to use location sharing in the message composer.
struct LocationSharingDemo: View {
    @State private var selectedLocation: LocationAttachmentPayload?
    @State private var customAttachments: [CustomAttachment] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Location Sharing Demo")
                .font(.title)
                .padding()
            
            if let location = selectedLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Location:")
                        .font(.headline)
                    
                    if let name = location.name {
                        Text("Name: \(name)")
                            .font(.body)
                    }
                    
                    if let address = location.address {
                        Text("Address: \(address)")
                            .font(.body)
                    }
                    
                    Text("Coordinates: \(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Location picker
            LocationPickerView { location in
                selectedLocation = location
                
                // Create a custom attachment with the location
                let customAttachment = CustomAttachment(
                    id: UUID().uuidString,
                    content: AnyAttachmentPayload(payload: location)
                )
                customAttachments = [customAttachment]
            }
            .frame(height: 300)
            
            // Show custom attachments preview
            if !customAttachments.isEmpty {
                LocationAttachmentsPreviewView(
                    addedCustomAttachments: customAttachments,
                    onCustomAttachmentTap: { attachment in
                        customAttachments.removeAll { $0.id == attachment.id }
                        if customAttachments.isEmpty {
                            selectedLocation = nil
                        }
                    }
                )
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LocationSharingDemo()
}
