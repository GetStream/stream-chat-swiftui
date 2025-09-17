//
// Copyright © 2025 Stream.io Inc. All rights reserved.
//

import MapKit
import SwiftUI

/// View for displaying location attachments in messages.
public struct LocationAttachmentView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let location: LocationAttachmentPayload
    let width: CGFloat
    let isFirst: Bool
    
    @State private var region: MKCoordinateRegion
    @State private var showingMap = false
    
    public init(
        location: LocationAttachmentPayload,
        width: CGFloat,
        isFirst: Bool
    ) {
        self.location = location
        self.width = width
        self.isFirst = isFirst
        
        // Initialize the map region
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Map preview
            Button {
                showingMap = true
            } label: {
                ZStack {
                    // Map placeholder
                    Rectangle()
                        .fill(Color(colors.background))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "map.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(colors.textLowEmphasis))
                                
                                Text("Tap to view map")
                                    .font(fonts.footnote)
                                    .foregroundColor(Color(colors.textLowEmphasis))
                            }
                        )
                    
                    // Location pin
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(Color(colors.tintColor))
                                .background(
                                    Circle()
                                        .fill(Color(colors.background))
                                        .frame(width: 20, height: 20)
                                )
                            Spacer()
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Location details
            VStack(alignment: .leading, spacing: 4) {
                if let name = location.name {
                    Text(name)
                        .font(fonts.bodyBold)
                        .foregroundColor(Color(colors.text))
                        .lineLimit(2)
                }
                
                if let address = location.address {
                    Text(address)
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                        .lineLimit(3)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(Color(colors.textLowEmphasis))
                    
                    Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                        .font(fonts.caption)
                        .foregroundColor(Color(colors.textLowEmphasis))
                    
                    Spacer()
                    
                    Text("Tap to open in Maps")
                        .font(fonts.caption)
                        .foregroundColor(Color(colors.tintColor))
                }
            }
            .padding(12)
            .background(Color(colors.background))
        }
        .frame(maxWidth: width)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(colors.innerBorder), lineWidth: 1)
        )
        .messageBubble(for: nil, isFirst: isFirst)
        .sheet(isPresented: $showingMap) {
            LocationMapView(location: location)
        }
    }
}

/// Full-screen map view for location attachments.
struct LocationMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    let location: LocationAttachmentPayload
    
    @State private var region: MKCoordinateRegion
    @State private var showingDirections = false
    
    init(location: LocationAttachmentPayload) {
        self.location = location
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Map view placeholder (in a real implementation, you'd use MapKit)
                ZStack {
                    Rectangle()
                        .fill(Color(colors.background))
                        .overlay(
                            VStack {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(colors.textLowEmphasis))
                                
                                Text("Map View")
                                    .font(fonts.headline)
                                    .foregroundColor(Color(colors.textLowEmphasis))
                                
                                Text("In a real implementation, this would show an interactive map")
                                    .font(fonts.footnote)
                                    .foregroundColor(Color(colors.textLowEmphasis))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        )
                    
                    // Location pin
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(colors.tintColor))
                                .background(
                                    Circle()
                                        .fill(Color(colors.background))
                                        .frame(width: 30, height: 30)
                                )
                            Spacer()
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                // Location details
                VStack(alignment: .leading, spacing: 8) {
                    if let name = location.name {
                        Text(name)
                            .font(fonts.headlineBold)
                            .foregroundColor(Color(colors.text))
                    }
                    
                    if let address = location.address {
                        Text(address)
                            .font(fonts.body)
                            .foregroundColor(Color(colors.textLowEmphasis))
                    }
                    
                    Text("\(String(format: "%.6f", location.latitude)), \(String(format: "%.6f", location.longitude))")
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(colors.background))
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Directions") {
                        openInMaps()
                    }
                }
            }
        }
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name ?? "Shared Location"
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
