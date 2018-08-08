//
//  FoodInfoView.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/4/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_ButtonThemer
import MaterialComponents.MaterialButtons_ColorThemer
import MaterialComponents.MaterialButtons_TypographyThemer
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialCards_ColorThemer
import MaterialComponents.MaterialPalettes
import Motion
import DCAnimationKit


class FoodInfoView : UIView{
    
    var delegate : actionDelegate? = nil{
        didSet{
            self.mainImageView.delegate = delegate
        }
    }
    var titleView : TitleView = TitleView()
    let offsett_TitleAndMainImage : CGFloat = 8.0
    var mainImageView : ImageViewer = ImageViewer.init(frame: CGRect.zero)
    let offset_MainImageAndDetail : CGFloat = 8.0
    var detailView : DetailView = DetailView()
    
    var foodObject : FoodModel? = nil{
        didSet{
            if(foodObject != nil){
               titleView.title = foodObject!.name
                if let imageData: NSData = NSData.init(contentsOf: URL.init(string: foodObject!.displayURL)!) {
                    mainImageView.currentImage = UIImage(data: imageData as Data)!
                }
                titleView.desc = foodObject!.cuisineType
                detailView.phoneNumber = foodObject!.phoneNumber
                detailView.rating = foodObject!.rating.description
                detailView.cost = foodObject!.cost
            }
        }
    }
    
    override func layoutSubviews() {
        if(titleView.titleLabel.frame.height == 0){
            titleView.updateLayout()
        }
        
        titleView.frame = CGRect.init(x: 0, y: 4, width: self.frame.width , height: titleView.titleLabel.frame.height + titleView.descLabel.frame.height + titleView.labelOffset )
        
        mainImageView.frame = CGRect.init(x: 5.0, y: titleView.frame.size.height + titleView.frame.origin.y + offsett_TitleAndMainImage, width: self.frame.width-10.0, height: 0.4*self.frame.height)
        mainImageView.updateLayout()
        
        detailView.frame = CGRect.init(x: 5.0, y: mainImageView.frame.origin.y + mainImageView.frame.height + offset_MainImageAndDetail, width: self.frame.width - 10, height: 0.10*self.frame.height)
        
        self.addSubview(titleView)
        self.addSubview(mainImageView)
        self.addSubview(detailView)
        
    }
    
    func animateViews(){
        self.mainImageView.isMotionEnabled = true;
        self.mainImageView.animateView()
    }
   
}

class TitleView : UIView {
    var title : String = ""
    var desc : String = ""
    var titleLabel : UILabel = UILabel.init(frame: CGRect.zero)
    var descLabel : UILabel = UILabel.init(frame: CGRect.zero)
    
    let titleLabelFont = "Audrey-Bold"
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
        
        descLabel.font = UIFont.init(name: descLabelFont, size: 17)
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
    var showMoreButton : MDCButton = MDCButton.init(frame: CGRect.zero)
    var showMenuButton : MDCButton = MDCButton.init(frame: CGRect.zero)
    var showReviewsButton : MDCButton = MDCButton.init(frame: CGRect.zero)
    let card = MDCCard()
    var delegate : actionDelegate? = nil
    var currentImage : UIImage = UIImage(){
        didSet{
            imageView.image = currentImage
        }
    }
    func animateView(){
//        isMotionEnabled = true
//        showMenuButton.isMotionEnabled = true;
//        showMoreButton.isMotionEnabled = true;
//        showReviewsButton.isMotionEnabled = true;

        showMenuButton.expand(into: self, finished: {self.showMoreButton.expand(into: self, finished: {self.showReviewsButton.expand(into: self, finished: {})})})
        
        
    }
    func updateLayout(){
    
        var size = CGSize.init(width: 0.6*self.frame.width, height: 0.8*self.frame.height)
        imageView.sizeToFit()
        if(imageView.frame.width < size.width && imageView.frame.height < size.height){
            imageView.center = CGPoint.init(x: size.width/2, y: self.frame.height/2)
        }
        else if(imageView.frame.width < size.width || imageView.frame.height < size.height){
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
            imageView.center = CGPoint.init(x: size.width/2, y: self.frame.height/2)
        }
        else{
            if(imageView.frame.width > imageView.frame.height){
                size = CGSize.init(width: 0.6*self.frame.width, height: self.frame.height)
            }
            else{
                size = CGSize.init(width: 0.6*self.frame.width, height: self.frame.height)
            }
            UIGraphicsBeginImageContext(CGSize.init(width: size.width, height: size.height))
            currentImage.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
            if let _ =  UIGraphicsGetImageFromCurrentImageContext(){
                currentImage = UIGraphicsGetImageFromCurrentImageContext()!
            }
            UIGraphicsEndImageContext()
            imageView.image = currentImage
            imageView.sizeToFit()
            imageView.frame = CGRect.init(x: 10.0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
        }
        let buttonXcenter = self.frame.width - (self.frame.width - (imageView.frame.origin.x + imageView.frame.width))/2
        
        showMoreButton.center = CGPoint.init(x: buttonXcenter, y: self.frame.height/2 - (showMoreButton.frame.height + 5.0))
        showMoreButton.sizeToFit()
        showMoreButton.inkStyle = .unbounded
        showMoreButton.maximumSize = CGSize.init(width: 0.34*self.frame.width, height: showMoreButton.frame.height)
        
        showMenuButton.frame = CGRect.init(x: 0, y: 0, width: showMoreButton.frame.width, height: showMoreButton.frame.height)
        showMenuButton.center = CGPoint.init(x: buttonXcenter, y: self.frame.height/2 )
        showMenuButton.inkStyle = .unbounded
        showMenuButton.maximumSize = CGSize.init(width: 0.3*self.frame.width, height: showMoreButton.frame.height)
        
        showReviewsButton.frame = CGRect.init(x: 0, y: 0, width: showMoreButton.frame.width, height: showMoreButton.frame.height)
        showReviewsButton.center = CGPoint.init(x: buttonXcenter, y: self.frame.height/2  + showReviewsButton.frame.height + 5.0)
        showReviewsButton.inkStyle = .unbounded
        showReviewsButton.maximumSize = CGSize.init(width: 0.3*self.frame.width, height: showMoreButton.frame.height)
        
        

    }
    
    
    override func layoutSubviews() {
        
        updateLayout()
        
        self.addSubview(card)
//        self.addSubview(imageView)
//        self.addSubview(showMoreButton)
//        self.addSubview(showMenuButton)
//        self.addSubview(showReviewsButton)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        card.addSubview(imageView)
        
        card.setShadowElevation( ShadowElevation.init(10), for: .normal)
    //        card.
        let typographyScheme = MDCTypographyScheme()
        //Reviews Button
        let colorSchemeReviewsButton = MDCSemanticColorScheme()
        colorSchemeReviewsButton.primaryColor = UIColor(red: CGFloat(0x1a) / 255.0,
                                                     green: CGFloat(0x2a) / 255.0,
                                                     blue: CGFloat(0x6c) / 255.0,
                                                     alpha: 1)
        colorSchemeReviewsButton.primaryColorVariant = UIColor(red: CGFloat(0xe1) / 255.0,
                                                            green: CGFloat(0xee) / 255.0,
                                                            blue: CGFloat(0xc3) / 255.0,
                                                            alpha: 1)
        
        colorSchemeReviewsButton.secondaryColor = UIColor(red: CGFloat(0xe1) / 255.0,
                                                       green: CGFloat(0xee) / 255.0,
                                                       blue: CGFloat(0xc3) / 255.0,
                                                       alpha: 1)
        let buttonSchemeReviewsButton = MDCButtonScheme()
        buttonSchemeReviewsButton.colorScheme = colorSchemeReviewsButton
        buttonSchemeReviewsButton.typographyScheme = typographyScheme
        
        MDCContainedButtonThemer.applyScheme(buttonSchemeReviewsButton, to: showReviewsButton)
        
        showReviewsButton.setTitle("Reviews", for: .normal)
        
        
        
        
        //Menu Button
        let colorSchemeMenuButton = MDCSemanticColorScheme()
        colorSchemeMenuButton.primaryColor = UIColor(red: CGFloat(0xb2) / 255.0,
                                                 green: CGFloat(0x1f) / 255.0,
                                                 blue: CGFloat(0x1f) / 255.0,
                                                 alpha: 1)
        colorSchemeMenuButton.primaryColorVariant = UIColor(red: CGFloat(0xe1) / 255.0,
                                                        green: CGFloat(0xee) / 255.0,
                                                        blue: CGFloat(0xc3) / 255.0,
                                                        alpha: 1)
        
        colorSchemeMenuButton.secondaryColor = UIColor(red: CGFloat(0xe1) / 255.0,
                                                   green: CGFloat(0xee) / 255.0,
                                                   blue: CGFloat(0xc3) / 255.0,
                                                   alpha: 1)
        let buttonSchemeMenuButton = MDCButtonScheme()
        
        buttonSchemeMenuButton.colorScheme = colorSchemeMenuButton
        buttonSchemeMenuButton.typographyScheme = typographyScheme
        
        MDCContainedButtonThemer.applyScheme(buttonSchemeMenuButton, to: showMenuButton)
        
        showMenuButton.setTitle("See Menu", for: .normal)
        //Photos Button
        let colorSchemePhotos = MDCSemanticColorScheme()
        //#06beb6
        colorSchemePhotos.primaryColor = UIColor(red: CGFloat(0x06) / 255.0,
                                           green: CGFloat(0xbe) / 255.0,
                                           blue: CGFloat(0xb6) / 255.0,
                                           alpha: 1)
        colorSchemePhotos.primaryColorVariant = UIColor(red: CGFloat(0xe1) / 255.0,
                                                  green: CGFloat(0xee) / 255.0,
                                                  blue: CGFloat(0xc3) / 255.0,
                                                  alpha: 1)
        
        colorSchemePhotos.secondaryColor = UIColor(red: CGFloat(0xe1) / 255.0,
                                                   green: CGFloat(0xee) / 255.0,
                                                   blue: CGFloat(0xc3) / 255.0,
                                                   alpha: 1)
        let buttonScheme = MDCButtonScheme()
        buttonScheme.colorScheme = colorSchemePhotos
        buttonScheme.typographyScheme = typographyScheme
        
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: showMoreButton)
        
        showMoreButton.setTitle("More Photos", for: .normal)
        
        showMoreButton.setTitleFont(UIFont.init(name: typographyScheme.button.fontName, size: 11), for: .normal)
        showMenuButton.setTitleFont(UIFont.init(name: typographyScheme.button.fontName, size: 11), for: .normal)
        showReviewsButton.setTitleFont(UIFont.init(name: typographyScheme.button.fontName, size: 11), for: .normal)
        
        updateLayout()
        MDCCardsColorThemer.applySemanticColorScheme(colorSchemePhotos, to: card)
        
        showMenuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func showMenu(){
        self.delegate!.didTapMenu()
    }
    @objc func showMoreImages(){
        
    }
    
}

class DetailView : UIView{
    
    var phoneNumber : String = ""{
        didSet{
            let text = "Phone : " + phoneNumber
            let attrStrting = NSMutableAttributedString.init(string: text)
            let attributes : Dictionary<NSAttributedStringKey, Any> = [NSAttributedStringKey.foregroundColor: UIColor.blue,
                                                                       NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
            attrStrting.setAttributes(attributes, range: NSRange.init(location: 7, length: text.count - 7))
            phoneLabel.attributedText = attrStrting
        }
    }
    var rating : String = ""{
        didSet{
            ratingLabel.text = "Rating: " + rating + "/5"
        }
    }
    var cost : String = ""{
        didSet{
            costLabel.text = "Cost: " + cost
        }
    }
    let phoneLabel : UILabel = UILabel()
    let ratingLabel : UILabel = UILabel()
    let costLabel : UILabel = UILabel()
    
    let font : UIFont = UIFont.init(name: "Cochin", size: 17)!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        phoneLabel.font = font
        ratingLabel.font = font
        costLabel.font = font

        phoneLabel.textAlignment = .center
        ratingLabel.textAlignment = .center
        costLabel.textAlignment = .center
    }
    
    func updateLayout(){
//        if let _ = phoneLabel.attributedText{
//            let attributedText : NSAttributedString = phoneLabel.attributedText!
//            phoneLabel.text = "Phone : " + phoneNumber
//            phoneLabel.sizeToFit()
//            phoneLabel.attributedText = attributedText
//        }
        phoneLabel.sizeToFit()
        phoneLabel.center = CGPoint.init(x: 0.30*self.frame.width, y: self.frame.height/2)
        ratingLabel.sizeToFit()
        ratingLabel.center = CGPoint.init(x: self.frame.width - (0.20*self.frame.width), y: self.frame.height/4)
        costLabel.sizeToFit()
        costLabel.center = CGPoint.init(x: self.frame.width - (0.20*self.frame.width), y: self.frame.height*(3/4))

    }
    
    override func layoutSubviews() {
        updateLayout()
        self.addSubview(phoneLabel)
        self.addSubview(ratingLabel)
        self.addSubview(costLabel)
    }
    
}


