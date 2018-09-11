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

/*
 Constants
     */
    
    let API_KEY = "AIzaSyC07x8Hf43hr5eVhY2DjcLb9GQWN0A8h2s"
    let AUTH_HEADER_VALUE = "Bearer aoH0X7ew0xQCsT-eZme66wHKkjr_pRIVmXXwB6al-UiHE-4W8Xz_lQTS9dNiFZgTuqb7KkIkKJCWEERysUGtsogiok87OjHA0LP1K-9TbzzUxXAicclOg7KYm_hlW3Yx"
    let LATITUDE = "latitude"
    let LONGITUDE = "longitude"
    let SEARCH_REQUEST = "https://api.yelp.com/v3/businesses/search"
    let BASE_REQUEST = "https://api.yelp.com/v3/businesses/"
    let AUTH_HEADER_KEY = "Authorization"
    let TOP_BUFFER : CGFloat = 20.0
    let GAP : CGFloat = 5.0
    var bgColor : UIColor = UIColor.init(red: 171/255.0, green: 208/255.0, blue: 240/255.0, alpha: 1)
    let yelpHeader: HTTPHeaders = [
        AUTH_HEADER_KEY: AUTH_HEADER_VALUE
    ]
    let CORNER_RADIUS = CGFloat.init(10.0)
    let filterButton : UIButton = UIButton.init()
    
/*
     The 2 states that the app can be in:
     1. Selected: When user has tapped on a restaurant and our map is out of view.
     2. UnSelected: When Map occupies full screen.
*/
enum displayState{
    case selected
    case unselected
}
    
/*
    Custom marker that has reference to the Restaurant that it represents.
 */
class CustomMarker :  GMSMarker{
    var foodModel : FoodModel = FoodModel();
}
    
class ViewController: UIViewController, actionDelegate {
    
    //MARK: Properties
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var infoView: FoodInfoView!
    
    /*
     Map of [RestaurantID : ReviewModel]
     We fetch the Reviews for a restaurant when we tap on the marker on the map.
     We store retreived reviews in this map, so that we dont have to fetch again during the same app session.
     TODO: Maybe store this in CoreData/UserDefaults if the fetch fails/no network.
         : Should not do this always since we want latest reviews and also the restaurantID's might change?
     */
    var reviewsMapping : Dictionary<String, [ReviewModel]> = Dictionary<String, [ReviewModel]>()
    
    /*
     Map of [RestaurantID : FoodDetailModel]
     Similar to the Reviews map. We fetch Detail when user taps on the marker.
     Similar use case and also potential TODO.
     */
    var detailsMapping : Dictionary<String, FoodDetailModel> = Dictionary<String, FoodDetailModel>()
    //TODO: Merge reviewsMapping and detailsMapping - basically 1 map for a RestaurantID
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    /*
     Default unselected.
     */
    var state : displayState = .unselected
    
    var currentSelectedRestaurantID : String = ""
    
    var currentSelectedRestaurantDetail : FoodDetailModel? = nil{
        didSet{
            detailsMapping[currentSelectedRestaurantID] = currentSelectedRestaurantDetail
        }
    }
    var currentSelectedRestaurantReviews : [ReviewModel]? = nil{
        didSet{
            reviewsMapping[currentSelectedRestaurantID] = currentSelectedRestaurantReviews
        }
    }
    
    /*
     The View Controller used by the photosDisplay.
     */
    var photosVC : UIViewController = UIViewController()
    
    /*
     The View Controller used by the MenuDisplay.
     */
    let m  = MenuVC();
    
    /*
     HTTP Client used for all http requests.
     */
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
        
        infoView.layer.cornerRadius = CORNER_RADIUS
        mapView.layer.cornerRadius = CORNER_RADIUS
        
        mapView.isMyLocationEnabled = true
    
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.distanceFilter = 100.0
        
        addFilterButton()
    
    }
    //TODO: implement animated removal
    func removeFilterButton(_ animated: Bool){
        if(animated){
           filterButton.removeFromSuperview()
        }
        else{
            filterButton.removeFromSuperview()
        }
    }
    
    func addFilterButton(){
        removeFilterButton(false)
        filterButton.setTitle("Filter", for: .normal)
        filterButton.titleLabel?.font = UIFont.init(name: "Cochin-Bold", size: 20)
        filterButton.setTitleColor(UIColor.orange, for: .normal)
        filterButton.sizeToFit()
        filterButton.frame = CGRect.init(x: (self.mapView.frame.origin.x + self.mapView.frame.width) - 80, y: self.mapView.frame.origin.y + 60, width: filterButton.frame.width + 15.0, height: filterButton.frame.height  )
        filterButton.layer.borderColor = UIColor.lightGray.cgColor
        filterButton.backgroundColor = bgColor
        filterButton.layer.borderWidth = 1.0
        filterButton.layer.cornerRadius = 5.0
        filterButton.clipsToBounds = true
        
        filterButton.addTarget(self, action: #selector(showFilterPanel), for: .touchUpInside)
        
        self.mapView.addSubview(filterButton)
    }
    var filterPanel : FilterPanel = FilterPanel()
    @objc func showFilterPanel(){
        filterPanel.removeFromSuperview()
        filterPanel.frame = CGRect.init(x: 0, y: 200, width: 300, height: 300);
        filterPanel.center = self.mapView.center
        self.view.addSubview(filterPanel)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        UIView.animate(withDuration: 0.5, animations: {self.updateFrame(size)})
    }
    
    //MARK: Layout
    func updateFrame(_ size: CGSize? = nil){
        var viewSize = self.view.frame.size
        let currentOrientationStatus = UIApplication.shared.statusBarOrientation
        if(size != nil){
            viewSize = size!
        }
    
        removeFilterButton(true)
        switch state {
        case .selected:
            if currentOrientationStatus == .portrait || currentOrientationStatus == .portraitUpsideDown{
                infoView.frame = CGRect.init(x: 10, y: TOP_BUFFER, width: viewSize.width-20, height: viewSize.height-100)
                mapView.frame = CGRect.init(x: 0, y: infoView.frame.height + infoView.frame.origin.y + GAP, width: viewSize.width, height: mapView.frame.height)
                
            }
            else{
                infoView.frame = CGRect.init(x: 5, y: TOP_BUFFER, width: viewSize.width-10, height: viewSize.height-40)
                mapView.frame = CGRect.init(x: 0, y: infoView.frame.height + infoView.frame.origin.y, width: viewSize.width, height:mapView.frame.height)
            }
            break;
        case .unselected:
            if currentOrientationStatus == .portrait || currentOrientationStatus == .portraitUpsideDown{
                mapView.frame = CGRect.init(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
                infoView.frame = CGRect.init(x: 10, y: 0, width: viewSize.width-20, height: 0)
            }
            else{
                mapView.frame = CGRect.init(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
                infoView.frame = CGRect.init(x: 10, y: 0, width: viewSize.width-20, height: 0)
            }
            break;
        }
        addFilterButton()
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
            if let _reviews = currentSelectedRestaurantReviews{
                infoView.isDisplayingReviews = true
                self.infoView.displayReviews(_reviews)
            }
        }
    }

    func didTapMenu() {
        m.delegate = self
        self.present(m, animated: true, completion: nil)
    }
    
    /**
     We need a strong reference to the datasource for the NYT photos viewer to work properly.
     Dont want an optional, hence init with a default Value.
     */
    var dataSourcePhoto = NYTPhotoViewerArrayDataSource()
    
    func didTapPhotos(){
        dataSourcePhoto = NYTPhotoViewerArrayDataSource.init(photos: currentSelectedRestaurantDetail?.photos)
        photosVC = NYTPhotosViewController.init(dataSource: dataSourcePhoto)
        self.present(photosVC, animated: true, completion:nil)
    }
    
    
    //MapView Tap Methods
    @objc func didTapMapMarker(){
        if(state == .selected){
            state = .unselected
            UIView.animate(withDuration: 1.0, animations: {
                self.infoView.shouldLayout = false;
                self.updateFrame()}, completion: { _ in
                    self.infoView.reset()
            })
        }
    }
    
    func showFoodOnMap(){
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
                        if(foodModel.cuisineType == .Pizza){
                            marker.icon = self.imageWithImage(image: UIImage.init(named: "pizza2")!, scaledToSize: CGSize.init(width: 30.0, height: 30.0))
                        }
                        else if(foodModel.cuisineType == .Coffee){
                            marker.icon = self.imageWithImage(image: UIImage.init(named: "coffee")!, scaledToSize: CGSize.init(width: 35.0, height: 35.0))
                        }
                        else if(foodModel.cuisineType == .Bar){
                            marker.icon = self.imageWithImage(image: UIImage.init(named: "bar")!, scaledToSize: CGSize.init(width: 30.0, height: 30.0))
                        }
                        else if(foodModel.cuisineType == .Seafood){
                            
                            
                            marker.icon = self.imageWithImage(image: UIImage.init(named: "seafood")!, scaledToSize: CGSize.init(width: 30.0, height: 30.0))
                        }
                        
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
        self.showFoodOnMap()
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
        didTapMapMarker()
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let selectedMarker = marker as! CustomMarker
        //populate the infoView
        self.infoView.foodObject = selectedMarker.foodModel
        currentSelectedRestaurantID = selectedMarker.foodModel.id
        //Check if we have the details for the current restraunt. If not, send request for it.
        if let detail = detailsMapping[currentSelectedRestaurantID]{
            currentSelectedRestaurantDetail = detail
        }
        else{
            //send Request
            self.httpClient?.requestForRestaurantDetails(currentSelectedRestaurantID)
        }
        
        if let reviews = reviewsMapping[currentSelectedRestaurantID]{
            currentSelectedRestaurantReviews = reviews
        }
        else{
            self.httpClient?.requestForReviews(currentSelectedRestaurantID)
        }
        
        //Update frame
        state = .selected
        self.infoView.isHidden = false;
        
        
        UIView.animate(withDuration: 1.0, animations: {
            self.infoView.shouldLayout = true
            self.updateFrame()
        },completion:{_ in

            self.isMotionEnabled = true;
            self.infoView.isMotionEnabled = true;
            self.infoView.animateViews()
           
        })
        
        
        return true;
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

