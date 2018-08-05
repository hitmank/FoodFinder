//
//  FoodInfoView.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/4/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit

class FoodInfoView : UIView{
    var nameLabel : UILabel = UILabel.init(frame: CGRect.zero)
    var mainImageView : UIImageView = UIImageView.init(frame: CGRect.zero)
    var cuisineLabel : UILabel = UILabel.init(frame: CGRect.zero)
    var foodObject : FoodModel? = nil{
        didSet{
            if(foodObject != nil){
                nameLabel.text = foodObject!.name
                if let imageData: NSData = NSData.init(contentsOf: URL.init(string: foodObject!.displayURL)!) {
                    mainImageView.image = UIImage(data: imageData as Data)
                }
                cuisineLabel.text = foodObject!.cuisineType
            }
        }
    }
    
    override func layoutSubviews() {
       
        nameLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: (30/100)*self.frame.size.height)
        mainImageView.frame = CGRect.init(x: 0, y: nameLabel.frame.size.height, width: self.frame.size.width, height: 0.4*self.frame.size.height)
        cuisineLabel.frame = CGRect.init(x: 0, y: nameLabel.frame.height + mainImageView.frame.height, width: self.frame.width, height: 0.3*self.frame.height)
        self.addSubview(nameLabel)
        self.addSubview(mainImageView)
        self.addSubview(cuisineLabel)
        
    }
    
   
}
