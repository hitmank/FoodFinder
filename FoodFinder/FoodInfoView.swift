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
    
    var titleView : TitleView = TitleView()
    let offsett_TitleAndMainImage : CGFloat = 8.0
    var mainImageView : ImageViewer = ImageViewer.init(frame: CGRect.zero)
    
    var foodObject : FoodModel? = nil{
        didSet{
            if(foodObject != nil){
               titleView.title = foodObject!.name
                if let imageData: NSData = NSData.init(contentsOf: URL.init(string: foodObject!.displayURL)!) {
                    mainImageView.currentImage = UIImage(data: imageData as Data)!
                }
                titleView.desc = foodObject!.cuisineType
            }
        }
    }
    
    override func layoutSubviews() {
        
        if(titleView.titleLabel.frame.height == 0){
            titleView.updateLayout()
        }
        titleView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: titleView.titleLabel.frame.height + titleView.descLabel.frame.height + titleView.labelOffset)
        
        mainImageView.frame = CGRect.init(x: 0, y: titleView.frame.size.height + titleView.frame.origin.y + offsett_TitleAndMainImage, width: self.frame.width, height: 0.4*self.frame.height)
        
        self.addSubview(titleView)
        self.addSubview(mainImageView)
        
    }
    
   
}

class TitleView : UIView {
    var title : String = ""
    var desc : String = ""
    var titleLabel : UILabel = UILabel.init(frame: CGRect.zero)
    var descLabel : UILabel = UILabel.init(frame: CGRect.zero)
    
    let titleLabelFont = "MarkerFelt"
    let descLabelFont = "Cochin"
    let labelOffset : CGFloat = 4.0

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateLayout(){
        titleLabel.font = UIFont.init(name: titleLabelFont, size: 35)
        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.sizeToFit()
        if(titleLabel.frame.width > self.frame.width){
            titleLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: titleLabel.frame.height)
        }
        else{
            titleLabel.frame = CGRect.init(x: 0, y: 0, width: titleLabel.frame.width, height: titleLabel.frame.height)
        }
        titleLabel.center = CGPoint.init(x: self.center.x, y: titleLabel.center.y)
        
        descLabel.font = UIFont.init(name: descLabelFont, size: 20)
        descLabel.text = desc
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.sizeToFit()
        if(descLabel.frame.width > self.frame.width){
            descLabel.frame = CGRect.init(x: 0, y: titleLabel.frame.height + labelOffset, width: self.frame.width, height: descLabel.frame.height)
        }
        else{
            descLabel.frame = CGRect.init(x: 0, y: titleLabel.frame.height + 4.0, width: descLabel.frame.width, height: descLabel.frame.height)
        }
        descLabel.center = CGPoint.init(x: self.center.x, y: descLabel.center.y)
    }
    
    override func layoutSubviews() {
        updateLayout()
        self.addSubview(titleLabel)
        self.addSubview(descLabel)
       
    }
}

class ImageViewer : UIView {
 
    var imageView : UIImageView = UIImageView.init(frame: CGRect.zero)
    var showMoreButton : UIButton = UIButton.init(frame: CGRect.zero)
    var currentImage : UIImage = UIImage(){
        didSet{
            imageView.image = currentImage
        }
    }
    
    override func layoutSubviews() {
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        if(imageView.frame.width > (0.7 * self.frame.width)){
            imageView.frame = CGRect.init(x: 0, y: 0, width: (0.7)*self.frame.size.width, height: self.frame.height)
        }
        else{
            imageView.frame = CGRect.init(x: 0, y: 0, width: imageView.frame.width, height: self.frame.height)
        }
        
        showMoreButton.setTitle("See Photos", for: .normal)
        showMoreButton.setTitleColor(UIColor.darkGray, for: .normal)
        showMoreButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 20)
        showMoreButton.layer.cornerRadius = 8.0
        showMoreButton.layer.borderWidth = 0.5
        
        showMoreButton.sizeToFit()
        showMoreButton.titleLabel?.adjustsFontSizeToFitWidth = true
        showMoreButton.frame = CGRect.init(x: self.frame.width - showMoreButton.frame.width + 2.0, y: 0, width: showMoreButton.frame.width, height: showMoreButton.frame.height)
        showMoreButton.center = CGPoint.init(x: showMoreButton.center.x, y: self.frame.height/2)
        
        self.addSubview(imageView)
        self.addSubview(showMoreButton)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        showMoreButton.addTarget(self, action: #selector(showMoreImages), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showMoreImages(){
        
    }
    
}

