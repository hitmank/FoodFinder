//
//  FoodModel.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/4/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import CoreLocation
import NYTPhotoViewer

enum CuisineType {
    case Pizza
    case Coffee
    case Bar
    case Seafood
    case Other
}


struct FoodModel {
    var name : String = ""
    var coordinates : CLLocationCoordinate2D = CLLocationCoordinate2D()
    var id : String = ""
    var phoneNumber : String = ""
    var displayURL : String = ""
    var cuisineType : CuisineType = .Other
    var cuisineText : String = ""
    
    var isClosed : Bool = false
    var rating : Double = 0.0
    var cost : String = ""
}

class Photo: NSObject, NYTPhoto {
    var imageData: Data? = nil
    
    var placeholderImage: UIImage? = nil
    
    var attributedCaptionTitle: NSAttributedString? = nil
    
    var attributedCaptionSummary: NSAttributedString? = nil
    
    var attributedCaptionCredit: NSAttributedString? = nil

    var image: UIImage? = nil
}

struct FoodDetailModel {
    var photos : [Photo] = []
}

struct ReviewModel{
    var reviewText      : String = ""
    var ratingGiven     : Double = 0.0
    var user            : UserModel = UserModel()
    var linkToReview    : String = ""
    var id              : String = ""
}

struct UserModel {
    var name : String = ""
    var id : String = ""
    var imageUrl : String = ""
}

class Parser{
    static func parseResult(_ result: NSDictionary) -> [FoodModel]?{
        
        if let businessList = result.value(forKey: "businesses") as? Array<NSDictionary>{
            var list : [FoodModel] = []
            for currentBusiness in businessList{
                var food = FoodModel()
                
                //id
                if let id = currentBusiness.value(forKey: "id") as? String{
                    food.id = id
                }
                
                //Name
                if let name = currentBusiness.value(forKey: "name") as? String{
                    food.name = name
                }
                
                //Cuisine
                var cuisine = "Cuisine:"
                if let categoryList = currentBusiness.value(forKey: "categories") as? Array<Dictionary<String, String>>{
                    for category in categoryList{
                        if let currCategory = category["title"]{
                            print(currCategory);
                            if(cuisine == "Cuisine:"){
                                cuisine = cuisine + " " + currCategory
                            }
                            else{
                                cuisine = cuisine + " ," + currCategory
                            }
                            
                        }
                        
                    }
                }
                food.cuisineText = cuisine
                
                //Main Image
                if let mainImageURL = currentBusiness.value(forKey: "image_url") as? String{
                     food.displayURL = mainImageURL
                }
                
                //Coordinates
                if let coordinates = currentBusiness.value(forKey: "coordinates") as? Dictionary<String, Double>{
                    let lat = coordinates[LATITUDE]
                    let long = coordinates[LONGITUDE]
                    if(lat != nil && long != nil){
                        food.coordinates = CLLocationCoordinate2D.init(latitude: lat!, longitude: long!)
                    }
                }
                
                //phone number
                if let number = currentBusiness.value(forKey: "display_phone") as? String{
                    food.phoneNumber = number
                }
                
                //isClosed
                if let closed = currentBusiness.value(forKey: "is_closed") as? Bool{
                    food.isClosed = closed
                }
                
                //rating
                if let rating = currentBusiness.value(forKey: "rating") as? Double{
                    food.rating = rating
                }
                
                //cost
                if let cost = currentBusiness.value(forKey: "price") as? String{
                    food.cost = cost
                }
                
                Parser.classifyCuisine(&food)
                
                list.append(food)
            }
            
            return list
            
        }
        
        
        
        
        return nil
    }
    
    static func parseDetailsResult(_ result: NSDictionary) -> FoodDetailModel?{
        var foodDetail = FoodDetailModel()
        if let photos = result["photos"] as? Array<String>{
            for pic in photos{
                if let imageData: NSData = NSData.init(contentsOf: URL.init(string: pic)!) {
                    let currPic = Photo()
                    currPic.image = UIImage.init(data: imageData as Data)
                    foodDetail.photos.append(currPic)
                }
                
            }
        }
        return foodDetail
    }
    
    static func parseReviewsResponse(_ result: NSDictionary) -> [ReviewModel]?{
        var reviews : [ReviewModel] = []
        if let allReviews = result["reviews"] as? Array<NSDictionary>{
            for currentReview in allReviews{
                var model = ReviewModel();
                if let rating = currentReview["rating"] as? Double{
                    model.ratingGiven = rating
                }
                if let id = currentReview["id"] as? String{
                    model.id = id
                }
                if let url = currentReview["url"] as? String{
                    model.linkToReview = url
                }
                if let text = currentReview["text"] as? String{
                    model.reviewText = text
                }
                var User = UserModel()
                if let userDict = currentReview["user"] as? NSDictionary{
                    if let name = userDict["name"] as? String{
                        User.name = name
                    }
                    if let userID = userDict["id"] as? String{
                        User.id = userID
                    }
                    if let imageURL = userDict["image_url"] as? String{
                        User.imageUrl = imageURL
                    }
                }
                model.user = User
                reviews.append(model)
            }
        }
        return reviews
    }
    
    static func classifyCuisine(_ model : inout FoodModel) {
        //Pizza
        if(model.name.contains("pizza") || model.name.contains("Pizza")){
            model.cuisineType = .Pizza
            return
        }
        if(model.cuisineText.contains("pizza") || model.cuisineText.contains("Pizza")){
            model.cuisineType = .Pizza
            return
        }
        //Coffee
        if(model.name.contains("coffee") || model.name.contains("Coffee") || model.name.contains("cafe") || model.name.contains("Cafe")){
            model.cuisineType = .Coffee
            return
        }
        if(model.cuisineText.contains("coffee") || model.cuisineText.contains("Coffee") || model.cuisineText.contains("cafe") || model.cuisineText.contains("Cafe")){
            model.cuisineType = .Coffee
            return
        }
        //Bar
        if(model.name.contains("bar") || model.name.contains("Bar") || model.name.contains("beer") || model.name.contains("Beer") || model.name.contains("wine") || model.name.contains("Wine") || model.name.contains("drinks") || model.name.contains("Drinks")){
            model.cuisineType = .Bar
            return
        }
        if(model.cuisineText.contains("bar") || model.cuisineText.contains("Bar") || model.cuisineText.contains("beer") || model.cuisineText.contains("Beer") || model.cuisineText.contains("wine") || model.cuisineText.contains("Wine") || model.cuisineText.contains("drinks") || model.cuisineText.contains("Drinks")){
            model.cuisineType = .Bar
            return
        }
        //Seafood
        if(model.name.contains("seafood") || model.name.contains("Seafood") || model.name.contains("fish") || model.name.contains("Fish")){
            model.cuisineType = .Seafood
            return
        }
        if(model.cuisineText.contains("seafood") || model.cuisineText.contains("Seafood") || model.cuisineText.contains("fish") || model.cuisineText.contains("Fish")){
            model.cuisineType = .Seafood
            return
        }
    }
    
    
}
