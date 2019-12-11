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
    let geoCoder = CLGeocoder()
    var directionsArray:[MKDirections] = []
    
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
    func getDirection(){
        guard let location = locationManager.location?.coordinate else{
            return
        }
        let request = creatDirectionRequest(from: location)
        let direction = MKDirections(request: request)
        resetMapView(withNew: direction)
        direction.calculate{[unowned self] (response, error)in
            guard let response = response else { return }
            for route in response.routes{
                let steps = route.steps
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    func creatDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request{
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    func resetMapView(withNew directions: MKDirections){
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        
        let _ = directionsArray.map { $0.cancel()}
    }
    
    
    @IBAction func btnShow(_ sender: UIButton) {
        
        //  let loc = getCenterLocation(for: mapView)
       // createAlert(title: "ABC", message: "")
        
        guard let lat = locationManager.location?.coordinate.latitude else {
            return
        }
        guard let long = locationManager.location?.coordinate.longitude else {
            return
        }
        
        self.getminutesfromorgin(currentlat: lat, currentlng: long)
    }
    
    func getminutesfromorgin(currentlat:Double,currentlng:Double)  {
        let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlng)
        let coordinate₁ = CLLocation(latitude:44.2312, longitude: 76.4860 )
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
//        let speed:Double = 20 // m/s
//        let time = distanceInMeters/speed
//        var mints =  2 * round(time/60.0)
//          if mints == 0 {
//
//             mints = mints + 5
//
//          }
//
//         print("time is \(time/60.0)")
        print(distanceInMeters)
        if distanceInMeters < 100000000{
            
            let geoCoder = CLGeocoder()
            
            geoCoder.cancelGeocode()
            geoCoder.reverseGeocodeLocation(coordinate₁){ [weak self](placemarks,error) in
                guard let self = self else{ return }
                if let _ = error {
                    return
                }
                guard let placemark = placemarks?.first else{
                    return
                }
                let streetNumber = placemark.subThoroughfare ?? ""
                let streetName = placemark.thoroughfare ?? ""
                let mix = streetNumber + streetName
                DispatchQueue.main.async {
                    self.createAlert(title: "", message: "",address: mix)
                    //  self.addressLable.text = "\(streetNumber) \(streetName)"
                }}}}
    @IBAction func goBtn(_ sender: UIButton) {
        getDirection()
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
        
        geoCoder.cancelGeocode()
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
    func createAlert(title:String,message:String,address:String){
        
        let alertController = UIAlertController(title: "Nearby Restuarant",message: address,preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        let cancleAction = UIAlertAction(title: "Cancle", style: .default, handler: nil)
               alertController.addAction(cancleAction)
        
   
        self.present(alertController, animated: true, completion: nil)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
    }
    
    
}
