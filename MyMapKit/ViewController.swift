//
//  ViewController.swift
//  MyMapKit
//
//  Created by HigherVisibility on 10/12/2019.
//  Copyright © 2019 ahmedHigherVisibility. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController {
    
 
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 1000
    var previouslocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated:  true)
        }
    }
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            //show alert user to turn this on
        }
    }
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case.authorizedWhenInUse:
            startTrackingUserLocation()
            break
        case.denied:
            break
        case.notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case.restricted:
            break
        case.authorizedAlways:
            break
     
        }
    }
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previouslocation = getCenterLocation(for: mapView)
    }
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
extension ViewController :CLLocationManagerDelegate{
    private func locationManager(_ manager: CLLocation, didChageAuthorization status: CLAuthorizationStatus){
        checkLocationAuthorization()
    }
}
extension ViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previouslocation = self.previouslocation else{ return }
        guard center.distance(from: previouslocation) > 50 else {return}
        self.previouslocation = center
        
        geoCoder.reverseGeocodeLocation(center){ [weak self](placemarks,error) in
            guard let self = self else{ return }
            if let _ = error {
                return
            }
            guard let placemark = placemarks?.first else{
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLable.text = "\(streetNumber) \(streetName)"
              
                
            }
        }
        
    }
}
