//
//  Place.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/10/25.
//

import Foundation
import SwiftData
import CoreLocation
import MapKit

@Model
final class Place {
    @Attribute(.unique) var id: UUID
    var displayName: String // Primary label in the UI
    var subtitle: String? // Optional secondary line
    var location: Location? // Coordinates + address bundle
    var notes: String?
    
    init(
        id: UUID = UUID(),
        displayName: String = "",
        subtitle: String? = nil,
        location: Location? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.subtitle = subtitle
        self.location = location
        self.notes = notes
    }
}

@MainActor
extension Place {
    static func from(mapItem: MKMapItem) -> Place {
        let display = mapItem.name ?? "Untitled"
        let place = Place(displayName: display)
        let coordinate = mapItem.placemark.coordinate
        
        let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemark = mapItem.placemark
        
        // Tier 1
        location.name = mapItem.name
        location.formattedAddress = [
            placemark.thoroughfare,
            [placemark.locality, placemark.administrativeArea].compactMap { $0 }.joined(separator: ", "),
            placemark.postalCode
        ].compactMap { $0 }.joined(separator: " ")
        
        // Tier 2 (optional)
        location.street = placemark.thoroughfare
        location.city = placemark.locality
        location.administrativeArea = placemark.administrativeArea
        location.postalCode = placemark.postalCode
        location.isoCountryCode = placemark.isoCountryCode
        
        place.subtitle = location.formattedAddress
        place.location = location
        
        return place
    }
    
    @discardableResult
    func fillAddress(from location: Location) async -> Bool {
        let cl = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        if #available(iOS 26.0, *) {
            // TODO: COME BACK AND IMPLEMENT THIS IN A FEW WEEKS!!!!!
        }
        
        // Fallback: Core Location reverse geocoding (as of iOS 18)
        do {
            if let placemark = try await reversePlacemark(lat: location.latitude, lon: location.longitude) {
                applyPlacemark(placemark, to: location)
                return true
            }
        } catch {
            // Ignore and return false for later handling
        }
        
        return false
    }
    
    private func reversePlacemark(lat: Double, lon: Double) async throws -> CLPlacemark? {
        try await withCheckedThrowingContinuation { continuation in
            let coreLocation = CLLocation(latitude: lat, longitude: lon)
            CLGeocoder().reverseGeocodeLocation(coreLocation) { placemarks, error in
                if let error {
                    continuation.resume(throwing: error)
                    
                    return
                }
                
                continuation.resume(returning: placemarks?.first)
            }
        }
    }
    
    private func applyPlacemark(_ placemark: CLPlacemark, to location: Location) {
        location.name = placemark.name
        location.formattedAddress = [
            placemark.thoroughfare,
            [placemark.locality, placemark.administrativeArea].compactMap { $0 }.joined(separator: ", "),
            placemark.postalCode
        ].compactMap { $0 }.joined(separator: " ")
        
        location.street = placemark.thoroughfare
        location.city = placemark.locality
        location.administrativeArea = placemark.administrativeArea
        location.postalCode = placemark.postalCode
        location.isoCountryCode = placemark.isoCountryCode
    }
}
