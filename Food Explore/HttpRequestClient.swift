//
//  HttpRequestClient.swift
//  FoodFinder
//
//  Created by Balakrishnan, Karan on 8/10/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import Alamofire

struct HttpRequestClient {
    let customer : ViewController
    
    func requestForReviews(_ id: String){
        let full_url = BASE_REQUEST + id + "/reviews"
        request(full_url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: yelpHeader).responseJSON(completionHandler: {response in
            
            if let jsonResult = response.result.value{
                if let responseToParse = jsonResult as? NSDictionary{
                    let parsedResult = Parser.parseReviewsResponse(responseToParse)
                    guard let detailResult = parsedResult else {return}
                    self.customer.currentSelectedRestaurantReviews = detailResult
                }
            }
            
            
        })
    }
    
    func requestForRestaurantDetails(_ id: String){
        let full_url = BASE_REQUEST + id
        Alamofire.request(full_url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: yelpHeader).responseJSON(completionHandler: {response in
            
            if let jsonResult = response.result.value{
                if let responseToParse = jsonResult as? NSDictionary{
                    let parsedResult = Parser.parseDetailsResult(responseToParse)
                    guard let detailResult = parsedResult else {return}
                    self.customer.currentSelectedRestaurantDetail = detailResult
                }
            }
        })
    }
}
