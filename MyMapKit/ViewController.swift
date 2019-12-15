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
     var annotationArray = [MKAnnotation]()
    var equipments = [[String:Any]]()
    var address:[[String:Any]] = [
        ["address name":"Bahadurabad","Latitute":24.8825,"long":67.0694],
        ["address name":"SaintJames","Latitute":51.5072,"long":-0.1353],
        ["address name":"Johar","Latitute":24.9204,"long":67.1344],
        ["address name":"PIB Colony","Latitute":24.8942,"long":67.0539],
        ["address name":"Nazimabad","Latitute":24.9107,"long":67.0311],
        ["address name":"New Town","Latitute":24.9999,"long":67.0648],
        ["address name":"Tariq Road","Latitute":24.871641,"long":67.059906],
        ["address name":"Sada-Bahar Hotel","Latitute":24.8237,"long":66.9791]]
    let myorigin = getminutesfromorgin
    @IBOutlet weak var addressLable: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var latt = 0.0
    var longg = 0.0
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 1500
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
        //self.mapView.removeAnnotation(annotation)

        equipments.removeAll()
        
        
        self.mapView.removeAnnotations(self.annotationArray)
      self.annotationArray.removeAll()
        
        guard let latitute = locationManager.location?.coordinate.latitude else {
            return
        }
        guard let long = locationManager.location?.coordinate.longitude else {
            return
        }
        for add in address{
            let lat = add["Latitute"]
            let lng = add["long"]
            let adds = add["address name"]
      
            let getdistance = self.getdistance(currentlat: latt, currentlong: longg, diclat: lat as! Double, diclong: lng as! Double)
           print(getdistance)
            
            if getdistance < 2000 {
                equipments.append(add)
                self.addPin(lat: lat as! Double, long: lng as! Double, title: adds as! String)
         }
        }
        print(equipments)
    }
    
    func addPin(lat:Double,long:Double,title:String) {
        
        let annotation = MKPointAnnotation()
       
        self.annotationArray.append(annotation)
      let centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude:long)
        annotation.coordinate = centerCoordinate
        annotation.title = title
        
        self.mapView.addAnnotations(self.annotationArray)
     
        
    }
     
    func getdistance(currentlat:Double,currentlong:Double,diclat:Double,diclong:Double)->Double {
        
        let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
        let coordinate₁ = CLLocation(latitude:diclat, longitude: diclong )
        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        return distanceInMeters
    }

func getminutesfromorgin(currentlat:Double,currentlng:Double)  {
        let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlng)
        let coordinate₁ = CLLocation(latitude:44.2312, longitude: 76.4860 )
       let distanceInMeters = coordinate₀.distance(from: coordinate₁)
      
        print(distanceInMeters)
        if distanceInMeters < 00{
            
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
    
    @IBAction func centerbtn(_ sender: UIButton) {
        centerViewOnUserLocation()
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
        self.latt = latitude
        self.longg = longitude
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
        guard center.distance(from: previouslocation) > 00 else {return}
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
        renderer.strokeColor = .white
        renderer.lineWidth = 3
        return renderer
    }
    
    
}
