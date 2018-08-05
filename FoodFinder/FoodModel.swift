//
//  FoodModel.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/4/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import CoreLocation

struct FoodModel {
    var name : String = ""
    var coordinates : CLLocationCoordinate2D = CLLocationCoordinate2D()
    var id : String = ""
    var phoneNumber : String = ""
    var displayURL : String = ""
    var cuisineType : String = ""
    
    var isClosed : Bool = false
    var rating : Double = 0.0
    var cost : String = ""
    
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
                            if(cuisine == "Cuisine:"){
                                cuisine = cuisine + " " + currCategory
                            }
                            else{
                                cuisine = cuisine + " ," + currCategory
                            }
                            
                        }
                        
                    }
                }
                food.cuisineType = cuisine
                
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
                
                
                list.append(food)
            }
            
            return list
            
        }
        
        
        
        
        return nil
    }
}
