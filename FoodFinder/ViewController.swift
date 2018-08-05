//
//  ViewController.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/3/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire


let API_KEY = "AIzaSyC07x8Hf43hr5eVhY2DjcLb9GQWN0A8h2s"
let AUTH_HEADER_VALUE = "Bearer aoH0X7ew0xQCsT-eZme66wHKkjr_pRIVmXXwB6al-UiHE-4W8Xz_lQTS9dNiFZgTuqb7KkIkKJCWEERysUGtsogiok87OjHA0LP1K-9TbzzUxXAicclOg7KYm_hlW3Yx"
let LATITUDE = "latitude"
let LONGITUDE = "longitude"
let SEARCH_REQUEST = "https://api.yelp.com/v3/businesses/search"
let AUTH_HEADER_KEY = "Authorization"
let TOP_BUFFER : CGFloat = 20.0

enum displayState{
    case selected
    case unselected
}
class CustomMarker :  GMSMarker{
    var foodModel : FoodModel = FoodModel();
}
class ViewController: UIViewController {
    @IBOutlet var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var state : displayState = .unselected
    var currentOrientation : UIDeviceOrientation = UIDevice.current.orientation
    
    @IBOutlet var infoView: FoodInfoView!
    

    @objc func didTap(){
        state = .unselected
        UIView.animate(withDuration: 1.0, animations: {self.updateFrame()})
    }
    required init?(coder aDecoder: NSCoder) {
        GMSServices.provideAPIKey(API_KEY)
        super.init(coder: aDecoder)
    }
    
    func updateFrame(_ size: CGSize? = nil){
        var viewSize = self.view.frame.size
        if(size != nil){
            viewSize = size!
        }
    
        switch state {
        case .selected:
            if currentOrientation == .portrait || currentOrientation == .portraitUpsideDown{
                infoView.frame = CGRect.init(x: 5, y: TOP_BUFFER, width: viewSize.width-10, height: viewSize.height-185)
                mapView.frame = CGRect.init(x: 10, y: infoView.frame.height + infoView.frame.origin.y, width: viewSize.width-20, height: viewSize.height - (infoView.frame.height + infoView.frame.origin.y))
            }
            else{
                infoView.frame = CGRect.init(x: 5, y: 0, width: viewSize.width-10, height: viewSize.height-40)
                mapView.frame = CGRect.init(x: 10, y: infoView.frame.height + infoView.frame.origin.y, width: viewSize.width-20, height: viewSize.height - (infoView.frame.height + infoView.frame.origin.y))
            }
            break;
        case .unselected:
            if currentOrientation == .portrait || currentOrientation == .portraitUpsideDown{
                mapView.frame = CGRect.init(x: 10, y: 0, width: viewSize.width-20, height: viewSize.height)
                infoView.frame = CGRect.init(x: 10, y: 0, width: viewSize.width-20, height: 0)
            }
            else{
                mapView.frame = CGRect.init(x: 10, y: 0, width: viewSize.width-20, height: viewSize.height)
                infoView.frame = CGRect.init(x: 10, y: 0, width: viewSize.width-20, height: 0)
            }
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(didTap))
        infoView.addGestureRecognizer(tapGes)
        infoView.layer.cornerRadius = 10.0
        mapView.layer.cornerRadius = 10.0
        
        mapView.isMyLocationEnabled = true
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        currentOrientation = UIDevice.current.orientation
        UIView.animate(withDuration: 0.5, animations: {self.updateFrame(size)})
    }
    
    func showFood(){
        let param : Parameters = [
            LATITUDE : self.currentLocation!.coordinate.latitude,
            LONGITUDE : self.currentLocation!.coordinate.longitude
        ]
        let headers: HTTPHeaders = [
            AUTH_HEADER_KEY: AUTH_HEADER_VALUE
        ]
        
        Alamofire.request(SEARCH_REQUEST, method: .get, parameters: param, encoding: URLEncoding.default , headers: headers).responseJSON(completionHandler: {response in
            
            if let jsonResult = response.result.value{
                if let responseToParse = jsonResult as? NSDictionary{
                    let parsedResult = Parser.parseResult(responseToParse)
                    guard let FoodList = parsedResult else {return}
                    for foodModel in FoodList{
                        let marker = CustomMarker()
                        marker.position = CLLocationCoordinate2D(latitude: foodModel.coordinates.latitude, longitude: foodModel.coordinates.longitude)
                        marker.foodModel = foodModel
                        marker.map = self.mapView
                    }
                }
            }
            else{
                //TODO: handle errors
            }
            
        })
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 10.0)
        
        mapView.camera = camera
        mapView.delegate = self
        self.currentLocation = location
        UIView.animate(withDuration: 0.5, animations: {self.updateFrame()})
        self.showFood()
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension ViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let selectedMarker = marker as! CustomMarker
        //populate the infoView with food details
        self.infoView.foodObject = selectedMarker.foodModel
        
        //Update frame
        state = .selected
        UIView.animate(withDuration: 1.0, animations: {
            self.updateFrame()
        })
        return true;
    }
}
