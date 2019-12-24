//
//  LocationRecorder.swift
//  MapSample
//
//  Created by 原口和音 on 2019/12/23.
//  Copyright © 2019 原口和音. All rights reserved.
//

import Foundation
import GooglePlaces

protocol LocationRecorderDelegate: class {
    func didUpdateLocation(_ location: CLLocation, for state: LocationRecorderState)
    func didRecordLocation(_ location: CLLocation)
    func didFinishRecordingLocation()
}

enum LocationRecorderState {
    case paused
    case idling
    case recording
}

class LocationRecorder: NSObject {
    private let locationManager: CLLocationManager
    weak var delegate: LocationRecorderDelegate?
    
    var state: LocationRecorderState = .paused
    
    var route = [CLLocation]()
    
    var currentLocation: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
        
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
        state = .idling
    }
    
    func startRecording() {
        if let current = currentLocation {
            route.append(current)
            delegate?.didUpdateLocation(current, for: .recording)
        }
        state = .recording
    }
    
    func stopRecording() {
//        locationManager.stopUpdatingLocation()
        
        guard !route.isEmpty else { print("!!! Route is empty!"); return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode( route.map { RouteElement(from: $0) } )
        
        print("!!!!\n" + String(data: data, encoding: .utf8)!)
        
        route.removeAll()
        
        state = .idling
        
        delegate?.didFinishRecordingLocation()
    }
}

extension LocationRecorder: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        switch state {
        case .recording:
            guard let last = route.last, location.distance(from: last) >= 1 else { break }
            route.append(location)
        default: break
        }
        
        delegate?.didUpdateLocation(location, for: state)
        
        currentLocation = location
        
        print("!!! updated\nlat: \(location.coordinate.latitude), lon: \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }
}
