//
//  ShoppingChecklist.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/2/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class ShoppingChecklist {
    var totalSpent: Decimal?
    var receiptImageData: Data?
    var storeName: String?
    var storeAddress: String?
    var latitude: Double?
    var longitude: Double?
    
    @Relationship
    var checklist: Checklist
    
    init(totalSpent: Decimal? = nil,
         receiptImageData: Data? = nil,
         storeName: String? = nil,
         storeAddress: String? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         checklist: Checklist
    ) {
        self.totalSpent = totalSpent
        self.receiptImageData = receiptImageData
        self.storeName = storeName
        self.storeAddress = storeAddress
        self.latitude = latitude
        self.longitude = longitude
        self.checklist = checklist
    }
}
