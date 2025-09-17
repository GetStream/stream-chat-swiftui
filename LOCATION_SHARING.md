# Location Sharing Feature

This document describes the location sharing feature added to the StreamChatSwiftUI SDK.

## Overview

The location sharing feature allows users to share their current location or static locations through the message composer. It integrates seamlessly with the existing attachment system using custom attachments.

## Features

- **Current Location Sharing**: Share your current GPS location
- **Static Location Sharing**: Share predefined locations (Home, Office, Restaurant, Park)
- **Location Preview**: Preview shared locations in the message composer
- **Interactive Location Display**: View shared locations in messages with map integration
- **Maps Integration**: Open shared locations in Apple Maps for directions

## Implementation Details

### Core Components

1. **LocationAttachmentPayload**: Defines the structure for location data
2. **LocationPickerView**: UI for selecting and sharing locations
3. **LocationAttachmentView**: Displays location attachments in messages
4. **LocationAttachmentPreviewView**: Shows location previews in the composer

### Data Structure

```swift
public struct LocationAttachmentPayload: AttachmentPayload {
    public static let type: AttachmentType = .location
    
    public let latitude: Double
    public let longitude: Double
    public let name: String?
    public let address: String?
}
```

### Usage

#### 1. Basic Location Sharing

```swift
// Create a location payload
let location = LocationAttachmentPayload(
    latitude: 37.7749,
    longitude: -122.4194,
    name: "San Francisco",
    address: "San Francisco, CA, USA"
)

// Create a custom attachment
let customAttachment = CustomAttachment(
    id: UUID().uuidString,
    content: AnyAttachmentPayload(payload: location)
)

// Add to composer
viewModel.addedCustomAttachments.append(customAttachment)
```

#### 2. Using the Location Picker

The location picker is automatically integrated into the message composer. Users can:

1. Tap the location button in the attachment picker
2. Choose to share their current location (requires location permissions)
3. Select from predefined static locations
4. Preview the selected location before sending

#### 3. Customizing Location Options

You can customize the static location options by modifying the `LocationPickerView`:

```swift
// In LocationPickerView.swift, modify the LazyVGrid section
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
    LocationOptionButton(
        title: "Your Custom Location",
        subtitle: "Custom Address",
        icon: "custom.icon"
    ) {
        shareStaticLocation(
            latitude: yourLatitude,
            longitude: yourLongitude,
            name: "Your Custom Location",
            address: "Custom Address"
        )
    }
    // Add more custom locations...
}
```

## Permissions

The location sharing feature requires location permissions for current location sharing:

1. Add `NSLocationWhenInUseUsageDescription` to your Info.plist
2. The app will automatically request location permissions when needed
3. Users can still use static location sharing without granting permissions

## Integration

The location sharing feature is automatically integrated into the message composer. No additional setup is required beyond the standard StreamChatSwiftUI integration.

### ViewFactory Integration

The feature extends the ViewFactory protocol with new methods:

```swift
func makeLocationPickerView(
    onLocationSelected: @escaping (LocationAttachmentPayload) -> Void
) -> some View

func makeLocationAttachmentView(
    location: LocationAttachmentPayload,
    width: CGFloat,
    isFirst: Bool
) -> some View
```

### MessageTypeResolver Integration

Location attachments are automatically detected and handled:

```swift
func hasLocationAttachment(message: ChatMessage) -> Bool {
    !message.attachments(payloadType: LocationAttachmentPayload.self).isEmpty
}
```

## Testing

The feature includes comprehensive tests covering:

- LocationAttachmentPayload creation and validation
- Attachment type definitions
- Picker state management
- Integration with the message system

Run tests with:
```bash
xcodebuild test -scheme StreamChatSwiftUI -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Demo

See `LocationSharingDemo.swift` for a complete example of how to use the location sharing feature in your app.

## Future Enhancements

Potential future improvements could include:

- Real-time location sharing
- Location history
- Custom location categories
- Integration with third-party map services
- Location-based message filtering
