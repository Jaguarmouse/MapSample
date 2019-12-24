//
//  RouteElement.swift
//  MapSample
//
//  Created by 原口和音 on 2019/12/24.
//  Copyright © 2019 原口和音. All rights reserved.
//

import Foundation
import CoreLocation

struct RouteElement: Codable {
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    
    init(from location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        timestamp = location.timestamp
    }
}
