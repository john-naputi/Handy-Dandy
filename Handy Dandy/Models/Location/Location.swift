//
//  Location.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/10/25.
//

import Foundation
import SwiftData
import CoreLocation
import MapKit

@Model
final class Location {
    @Attribute(.unique) var id: UUID
    
    // Core Location primitives
    var latitude: Double // CLLocationDegrees
    var longitude: Double
    
    // Tier 1 Labels
    var name: String? // e.g., Costco
    var formattedAddress: String? // e.g., 123 Main St, Denver, CO, 80202
    
    // Tier 2 (structured, optional)
    var street: String?
    var city: String?
    var administrativeArea: String?
    var postalCode: String?
    var isoCountryCode: String?
    
    init(
        id: UUID = UUID(),
        latitude: Double = 0,
        longitude: Double = 0,
        name: String? = nil,
        formattedAddress: String? = nil,
        street: String? = nil,
        city: String? = nil,
        administrativeArea: String? = nil,
        postalCode: String? = nil,
        isoCountryCode: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.formattedAddress = formattedAddress
        self.street = street
        self.city = city
        self.administrativeArea = administrativeArea
        self.postalCode = postalCode
        self.isoCountryCode = isoCountryCode
    }
}

extension Location {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    func region(span: CLLocationDegrees = 0.01) -> MKCoordinateRegion {
        .init(center: coordinate, span: .init(latitudeDelta: span, longitudeDelta: span))
    }
}
