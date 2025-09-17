//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import StreamChat
@testable import StreamChatSwiftUI
import XCTest

final class LocationAttachment_Tests: XCTestCase {
    func testLocationAttachmentPayload() {
        // Given
        let latitude = 37.7749
        let longitude = -122.4194
        let name = "Test Location"
        let address = "123 Test Street"
        
        // When
        let locationPayload = LocationAttachmentPayload(
            latitude: latitude,
            longitude: longitude,
            name: name,
            address: address
        )
        
        // Then
        XCTAssertEqual(locationPayload.latitude, latitude)
        XCTAssertEqual(locationPayload.longitude, longitude)
        XCTAssertEqual(locationPayload.name, name)
        XCTAssertEqual(locationPayload.address, address)
        XCTAssertEqual(locationPayload.type, .location)
        XCTAssertEqual(locationPayload.id, "\(latitude)-\(longitude)")
    }
    
    func testLocationAttachmentPayloadWithoutOptionalFields() {
        // Given
        let latitude = 37.7749
        let longitude = -122.4194
        
        // When
        let locationPayload = LocationAttachmentPayload(
            latitude: latitude,
            longitude: longitude
        )
        
        // Then
        XCTAssertEqual(locationPayload.latitude, latitude)
        XCTAssertEqual(locationPayload.longitude, longitude)
        XCTAssertNil(locationPayload.name)
        XCTAssertNil(locationPayload.address)
        XCTAssertEqual(locationPayload.type, .location)
        XCTAssertEqual(locationPayload.id, "\(latitude)-\(longitude)")
    }
    
    func testAttachmentTypeLocation() {
        // Given & When
        let locationType = AttachmentType.location
        
        // Then
        XCTAssertEqual(locationType.rawValue, "location")
    }
    
    func testAttachmentPickerStateLocation() {
        // Given & When
        let locationState = AttachmentPickerState.location
        
        // Then
        XCTAssertNotNil(locationState)
    }
    
    func testAttachmentPickerTypeLocation() {
        // Given & When
        let locationType = AttachmentPickerType.location
        
        // Then
        XCTAssertNotNil(locationType)
    }
}
