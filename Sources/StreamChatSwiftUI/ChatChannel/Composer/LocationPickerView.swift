//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import CoreLocation
import SwiftUI

/// View for picking and sharing location.
public struct LocationPickerView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let onLocationSelected: (LocationAttachmentPayload) -> Void
    
    @State private var currentLocation: CLLocation?
    @State private var locationName: String = ""
    @State private var locationAddress: String = ""
    @State private var isLocationLoading = false
    @State private var locationError: String?
    
    private let locationManager = CLLocationManager()
    
    public init(onLocationSelected: @escaping (LocationAttachmentPayload) -> Void) {
        self.onLocationSelected = onLocationSelected
    }
    
    public var body: some View {
        AttachmentTypeContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text("Share Location")
                    .font(fonts.headlineBold)
                    .foregroundColor(Color(colors.text))
                    .standardPadding()
                
                VStack(spacing: 12) {
                    // Current location button
                    Button {
                        requestCurrentLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(Color(colors.tintColor))
                            
                            VStack(alignment: .leading) {
                                Text("Share Current Location")
                                    .font(fonts.bodyBold)
                                    .foregroundColor(Color(colors.text))
                                
                                if isLocationLoading {
                                    Text("Getting location...")
                                        .font(fonts.footnote)
                                        .foregroundColor(Color(colors.textLowEmphasis))
                                } else if let error = locationError {
                                    Text(error)
                                        .font(fonts.footnote)
                                        .foregroundColor(Color(colors.alert))
                                } else {
                                    Text("Tap to share your current location")
                                        .font(fonts.footnote)
                                        .foregroundColor(Color(colors.textLowEmphasis))
                                }
                            }
                            
                            Spacer()
                            
                            if isLocationLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding()
                        .background(Color(colors.background))
                        .cornerRadius(8)
                    }
                    .disabled(isLocationLoading)
                    
                    Divider()
                    
                    // Static location options
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Share")
                            .font(fonts.bodyBold)
                            .foregroundColor(Color(colors.text))
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            LocationOptionButton(
                                title: "Home",
                                subtitle: "123 Main St",
                                icon: "house.fill"
                            ) {
                                shareStaticLocation(
                                    latitude: 37.7749,
                                    longitude: -122.4194,
                                    name: "Home",
                                    address: "123 Main St"
                                )
                            }
                            
                            LocationOptionButton(
                                title: "Office",
                                subtitle: "456 Business Ave",
                                icon: "building.2.fill"
                            ) {
                                shareStaticLocation(
                                    latitude: 37.7849,
                                    longitude: -122.4094,
                                    name: "Office",
                                    address: "456 Business Ave"
                                )
                            }
                            
                            LocationOptionButton(
                                title: "Restaurant",
                                subtitle: "789 Food St",
                                icon: "fork.knife"
                            ) {
                                shareStaticLocation(
                                    latitude: 37.7649,
                                    longitude: -122.4294,
                                    name: "Restaurant",
                                    address: "789 Food St"
                                )
                            }
                            
                            LocationOptionButton(
                                title: "Park",
                                subtitle: "321 Nature Blvd",
                                icon: "tree.fill"
                            ) {
                                shareStaticLocation(
                                    latitude: 37.7549,
                                    longitude: -122.4394,
                                    name: "Park",
                                    address: "321 Nature Blvd"
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            setupLocationManager()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = LocationManagerDelegate { location in
            DispatchQueue.main.async {
                self.currentLocation = location
                self.isLocationLoading = false
                self.locationError = nil
            }
        } onError: { error in
            DispatchQueue.main.async {
                self.isLocationLoading = false
                self.locationError = error.localizedDescription
            }
        }
    }
    
    private func requestCurrentLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = "Location services are disabled"
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = "Location access denied"
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationLoading = true
            locationError = nil
            locationManager.requestLocation()
        @unknown default:
            locationError = "Unknown location authorization status"
        }
    }
    
    private func shareStaticLocation(
        latitude: Double,
        longitude: Double,
        name: String,
        address: String
    ) {
        let location = LocationAttachmentPayload(
            latitude: latitude,
            longitude: longitude,
            name: name,
            address: address
        )
        onLocationSelected(location)
    }
}

/// Button for location options in the picker.
struct LocationOptionButton: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(colors.tintColor))
                
                Text(title)
                    .font(fonts.footnoteBold)
                    .foregroundColor(Color(colors.text))
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(fonts.caption)
                    .foregroundColor(Color(colors.textLowEmphasis))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(colors.background))
            .cornerRadius(8)
        }
    }
}

/// Location manager delegate to handle location updates.
private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    private let onLocationUpdate: (CLLocation) -> Void
    private let onError: (Error) -> Void
    
    init(onLocationUpdate: @escaping (CLLocation) -> Void, onError: @escaping (Error) -> Void) {
        self.onLocationUpdate = onLocationUpdate
        self.onError = onError
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocationUpdate(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
