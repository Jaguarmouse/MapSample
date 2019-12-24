//
//  ViewController.swift
//  MapSample
//
//  Created by 原口和音 on 2019/11/23.
//  Copyright © 2019 原口和音. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
        
    var routePath = GMSMutablePath()
    var route: GMSPolyline!
    
    let locationRecorder = LocationRecorder()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 0,
                                              longitude: 0,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true

        // Add the map to the view, hide it until we've got a location update.
        view.insertSubview(mapView, belowSubview: recordButton)
        mapView.isHidden = true
        
        route = GMSPolyline(path: routePath)
        route.map = mapView
        route.strokeWidth = 10
        
        recordButton.layer.cornerRadius = 6
        
        locationRecorder.delegate = self
        locationRecorder.startUpdating()
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        switch locationRecorder.state {
        case .idling:
            locationRecorder.startRecording()
            recordButton.setTitle("Finish", for: .normal)
        case .recording:
            locationRecorder.stopRecording()
            recordButton.setTitle("Start", for: .normal)
        default: break
        }
    }

}

extension ViewController: LocationRecorderDelegate {
    func didUpdateLocation(_ location: CLLocation, for state: LocationRecorderState) {
        mapView.isHidden = false
        
        mapView.animate(toLocation: location.coordinate)
    }
    
    func didRecordLocation(_ location: CLLocation) {
        routePath.add(location.coordinate)
        route.path = routePath
    }
    
    func didFinishRecordingLocation() {
        routePath.removeAllCoordinates()
        route.path = routePath
        mapView.clear()
        route.map = mapView
    }
}
