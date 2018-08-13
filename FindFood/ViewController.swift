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
import DCAnimationKit
import Motion
import NYTPhotoViewer

let API_KEY = "AIzaSyC07x8Hf43hr5eVhY2DjcLb9GQWN0A8h2s"
let AUTH_HEADER_VALUE = "Bearer aoH0X7ew0xQCsT-eZme66wHKkjr_pRIVmXXwB6al-UiHE-4W8Xz_lQTS9dNiFZgTuqb7KkIkKJCWEERysUGtsogiok87OjHA0LP1K-9TbzzUxXAicclOg7KYm_hlW3Yx"
let LATITUDE = "latitude"
let LONGITUDE = "longitude"
let SEARCH_REQUEST = "https://api.yelp.com/v3/businesses/search"
let BASE_REQUEST = "https://api.yelp.com/v3/businesses/"
let AUTH_HEADER_KEY = "Authorization"
let TOP_BUFFER : CGFloat = 20.0
let GAP : CGFloat = 5.0
var bgColor : UIColor = UIColor.init(red: 58/255.0, green: 97/255.0, blue: 134/255.0, alpha: 1)
let yelpHeader: HTTPHeaders = [
    AUTH_HEADER_KEY: AUTH_HEADER_VALUE
]
    
    
    
enum displayState{
    case selected
    case unselected
}
    
    
    
class CustomMarker :  GMSMarker{
    var foodModel : FoodModel = FoodModel();
}
    
    
    
    
class ViewController: UIViewController, actionDelegate {
    
    //MARK: Properties
    @IBOutlet var mapView: GMSMapView!
    var reviewsMapping : Dictionary<String, [ReviewModel]> = Dictionary<String, [ReviewModel]>()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var state : displayState = .unselected
    var currentOrientation : UIDeviceOrientation = UIDevice.current.orientation
    var detailsMapping : Dictionary<String, FoodDetailModel> = Dictionary<String, FoodDetailModel>()
    var currentSelectedRestrauntID : String = ""
    var currentSelectedRestrauntDetail : FoodDetailModel? = nil{
        didSet{
            detailsMapping[currentSelectedRestrauntID] = currentSelectedRestrauntDetail
        }
    }
    var currentSelectedRestrauntReviews : [ReviewModel]? = nil{
        didSet{
            reviewsMapping[currentSelectedRestrauntID] = currentSelectedRestrauntReviews
        }
    }
    var photosVC : UIViewController = UIViewController()
    @IBOutlet var infoView: FoodInfoView!
    var httpClient : HttpRequestClient? = nil
    
    
    
    //MARK: UIView Methods
    required init?(coder aDecoder: NSCoder) {
        GMSServices.provideAPIKey(API_KEY)
        super.init(coder: aDecoder)
    }
    override func viewWillLayoutSubviews() {
        updateFrame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        for family: String in UIFont.familyNames
        //        {
        //            print("\(family)")
        //            for names: String in UIFont.fontNames(forFamilyName: family)
        //            {
        //                print("== \(names)")
        //            }
        //        }
        self.httpClient = HttpRequestClient(customer: self);
        infoView.actionDelegate = self
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        currentOrientation = UIDevice.current.orientation
        
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
    
    //MARK: Layout
    func updateFrame(_ size: CGSize? = nil){
        var viewSize = self.view.frame.size
        let currentOrientationStatus = UIApplication.shared.statusBarOrientation
        if(size != nil){
            viewSize = size!
        }
    
        switch state {
        case .selected:
            if currentOrientationStatus == .portrait || currentOrientationStatus == .portraitUpsideDown{
                infoView.frame = CGRect.init(x: 10, y: TOP_BUFFER, width: viewSize.width-20, height: viewSize.height-100)
//                [self.infoView bounceIntoView:self.view direction:DCAnimationDirectionTop];
                mapView.frame = CGRect.init(x: 10, y: infoView.frame.height + infoView.frame.origin.y + GAP, width: viewSize.width-20, height: mapView.frame.height)
                
            }
            else{
                infoView.frame = CGRect.init(x: 5, y: TOP_BUFFER, width: viewSize.width-10, height: viewSize.height-40)
                mapView.frame = CGRect.init(x: 10, y: infoView.frame.height + infoView.frame.origin.y, width: viewSize.width-20, height:mapView.frame.height)
            }
            break;
        case .unselected:
            if currentOrientationStatus == .portrait || currentOrientationStatus == .portraitUpsideDown{
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
    
    //MARK: InfoView Tap Delegate Methods
    func didTapReviews() {
        if infoView.isDisplayingReviews{
            UIView.animate(withDuration: 0.8, animations: {
                self.infoView.isAnimating  = true
                self.infoView.reviewDisplayView.frame = CGRect.init(x: self.infoView.reviewDisplayView.frame.origin.x, y: self.infoView.reviewDisplayView.frame.origin.y, width: self.infoView.reviewDisplayView.frame.width, height: 0)
                
            }, completion:{_ in
                self.infoView.isAnimating = false
                self.infoView.reviewDisplayView.removeFromSuperview()
                self.infoView.reviewDisplayView = ReviewDisplayView.init(frame: CGRect.zero, reviewsToDisplay: [])
                self.infoView.isDisplayingReviews = false
                self.infoView.layoutSubviews()
                
            })
            
            
            
        }
        else{
            if let _reviews = currentSelectedRestrauntReviews{
                infoView.isDisplayingReviews = true
                self.infoView.displayReviews(_reviews)
            }
        }
    }
    func didTapMenu1() {
        self.dismiss(animated: true, completion: nil)
    }
    let m  = MenuVC();
    func didTapMenu() {
        m.delegate = self
        self.present(m, animated: true, completion: nil)
    }
    var dataSourcePhto = NYTPhotoViewerArrayDataSource()
    func didTapPhotos(){
        self.dataSourcePhto = NYTPhotoViewerArrayDataSource.init(photos: currentSelectedRestrauntDetail?.photos)
        photosVC = NYTPhotosViewController.init(dataSource: self.dataSourcePhto)
        self.present(photosVC, animated: true, completion:nil)
    }
    
    //MapView Tap Methods
    @objc func didTap(){
        if(state == .selected){
            state = .unselected
            UIView.animate(withDuration: 1.0, animations: {
                self.view.backgroundColor = UIColor.lightGray
                self.infoView.isHidden = true;
                self.updateFrame()})
        }
    }
    
    func showFood(){
        let param : Parameters = [
            LATITUDE : self.currentLocation!.coordinate.latitude,
            LONGITUDE : self.currentLocation!.coordinate.longitude
        ]
        
        
        Alamofire.request(SEARCH_REQUEST, method: .get, parameters: param, encoding: URLEncoding.default , headers: yelpHeader).responseJSON(completionHandler: {response in
            
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
                                              zoom: 15.0)
        
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
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        didTap()
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let selectedMarker = marker as! CustomMarker
        //populate the infoView
        self.infoView.foodObject = selectedMarker.foodModel
        currentSelectedRestrauntID = selectedMarker.foodModel.id
        //Check if we have the details for the current restraunt. If not, send request for it.
        if let detail = detailsMapping[currentSelectedRestrauntID]{
            currentSelectedRestrauntDetail = detail
        }
        else{
            //send Request
            self.httpClient?.requestForRestaurantDetails(currentSelectedRestrauntID)
        }
        
        if let reviews = reviewsMapping[currentSelectedRestrauntID]{
            currentSelectedRestrauntReviews = reviews
        }
        else{
            self.httpClient?.requestForReviews(currentSelectedRestrauntID)
        }
        
        //Update frame
        state = .selected
        self.infoView.isHidden = false;
        

        UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = bgColor
            self.updateFrame()
        },completion:{_ in

            self.isMotionEnabled = true;
            self.infoView.isMotionEnabled = true;
            self.infoView.animateViews()
           
        })
        
        
        return true;
    }
}

