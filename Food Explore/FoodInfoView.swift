
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


let shadowColor = UIColor.darkGray

class FoodInfoView : UIScrollView{
    var isAnimating = false
    func displayReviews(_ reviews : [ReviewModel]){
        
        self.reviewDisplayView = ReviewDisplayView.init(frame: CGRect.init(x: 8, y: self.mainImageView.frame.origin.y + self.mainImageView.frame.height + self.offset_MainImageAndDetail, width: self.frame.width-16,height: (self.frame.height - 10.0) - (self.mainImageView.frame.origin.y + self.mainImageView.frame.height + self.offset_MainImageAndDetail)), reviewsToDisplay: reviews)
        let height = self.reviewDisplayView.frame.height
         self.reviewDisplayView.frame = CGRect.init(x: self.reviewDisplayView.frame.origin.x, y: self.reviewDisplayView.frame.origin.y, width: self.reviewDisplayView.frame.width, height: 0)
         self.addSubview(self.reviewDisplayView);
        UIView.animate(withDuration: 1.0, animations: {
           
 self.reviewDisplayView.frame = CGRect.init(x: self.reviewDisplayView.frame.origin.x, y: self.reviewDisplayView.frame.origin.y, width: self.reviewDisplayView.frame.width, height: height)
//            self.reviewDisplayView!.frame = CGRect.init(x: self.detailView.frame.origin.x, y: self.detailView.frame.origin.y, width: self.detailView.frame.width, height: 50)
            self.detailView.frame = CGRect.init(x: 5, y: self.mainImageView.frame.origin.y + self.mainImageView.frame.height + self.offset_MainImageAndDetail + height, width: self.frame.width-10.0, height: 0.10*self.frame.height)
            
            
            
        }, completion: { _ in
                
            
            
            
        })
    }
    var actionDelegate : actionDelegate? = nil{
        didSet{
            self.mainImageView.delegate = actionDelegate
        }
    }
    var titleView : TitleView = TitleView()
    let offsett_TitleAndMainImage : CGFloat = 8.0
    var mainImageView : ImageViewer = ImageViewer.init(frame: CGRect.zero)
    let offset_MainImageAndDetail : CGFloat = 8.0
    var reviewDisplayView : ReviewDisplayView = ReviewDisplayView.init(frame: CGRect.zero, reviewsToDisplay: [])

    var detailView : DetailView = DetailView()
    var isDisplayingReviews  = false
    var foodObject : FoodModel? = nil{
        didSet{
            if(foodObject != nil){
               titleView.title = foodObject!.name
                if let imageData: NSData = NSData.init(contentsOf: URL.init(string: foodObject!.displayURL)!) {
                    mainImageView.currentImage = UIImage(data: imageData as Data)!
                }
                mainImageView.delegate = actionDelegate
                titleView.desc = foodObject!.cuisineType
                detailView.phoneNumber = foodObject!.phoneNumber
                detailView.rating = foodObject!.rating.description
                detailView.cost = foodObject!.cost
            }
        }
    }
    
    var shouldLayout : Bool = true;
    override func layoutSubviews() {
        
        if(shouldLayout){
            
            self.reviewDisplayView.clipsToBounds = true
            if(!isAnimating){
                if(titleView.titleLabel.frame.height == 0){
                    titleView.updateLayout()
                }
                
                titleView.frame = CGRect.init(x: 6, y: 4, width: self.frame.width-12 , height: titleView.titleLabel.frame.height + titleView.descLabel.frame.height + titleView.labelOffset )
                
                mainImageView.frame = CGRect.init(x: 5.0, y: titleView.frame.size.height + titleView.frame.origin.y + offsett_TitleAndMainImage, width: self.frame.width-10.0, height: 0.4*self.frame.height)
                mainImageView.updateLayout()
                
                
               self.detailView.frame = CGRect.init(x: self.detailView.frame.origin.x, y: self.mainImageView.frame.origin.y + self.mainImageView.frame.height + offset_MainImageAndDetail +  self.reviewDisplayView.frame.height, width: self.frame.width-10.0, height: 0.10*self.frame.height)
                
                self.addSubview(titleView)
                self.addSubview(mainImageView)
                self.addSubview(detailView)
            }
            else{
                UIView.animate(withDuration: 0.8, animations: {
                    
                    if(self.titleView.titleLabel.frame.height == 0){
                        self.titleView.updateLayout()
                    }
                    
                    self.titleView.frame = CGRect.init(x: 6, y: 4, width: self.frame.width-12 , height: self.titleView.titleLabel.frame.height + self.titleView.descLabel.frame.height + self.titleView.labelOffset )
                    
                    self.mainImageView.frame = CGRect.init(x: 5.0, y: self.titleView.frame.size.height + self.titleView.frame.origin.y + self.offsett_TitleAndMainImage, width: self.frame.width-10.0, height: 0.4*self.frame.height)
                    self.mainImageView.updateLayout()
                    
                    
                    self.detailView.frame = CGRect.init(x: self.detailView.frame.origin.x, y: self.mainImageView.frame.origin.y + self.mainImageView.frame.height + self.offset_MainImageAndDetail +  self.reviewDisplayView.frame.height, width: self.frame.width-10.0, height: 0.10*self.frame.height)
                    
                    self.addSubview(self.titleView)
                    self.addSubview(self.mainImageView)
                    self.addSubview(self.detailView)
                })
            }
       
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowRadius = 10.0;
            self.layer.shadowOffset = CGSize(width: 5.0, height: 1.0)
            self.layer.shadowOpacity = 1.0
        }

    
    }
    
    func animateViews(){
        self.mainImageView.isMotionEnabled = true;
        self.mainImageView.animateView()
    }
    
    func reset(){
        self.removeCurrentAnimations()
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        self.foodObject = nil;
        self.titleView = TitleView()
        self.detailView = DetailView()
        self.reviewDisplayView = ReviewDisplayView.init(frame: CGRect.zero, reviewsToDisplay: [])
        self.mainImageView = ImageViewer.init(frame: CGRect.zero)
    }
    
}

class TitleView : UIView {
    var title : String = ""
    var desc : String = ""
    var titleLabel : UILabel = UILabel.init(frame: CGRect.zero)
    var descLabel : UILabel = UILabel.init(frame: CGRect.zero)
//    "Audrey-Bold"
    let titleLabelFont = "Billabong"
    let descLabelFont = "Cochin"
    let labelOffset : CGFloat = 4.0
    
   
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateLayout(){
        titleLabel.font = UIFont.init(name: titleLabelFont, size: 38)
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
        
        let attributedString = NSMutableAttributedString(string: showMenuButton.title(for: .normal)!)
        
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        showMenuButton.setAttributedTitle(attributedString, for: .normal)
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
        showMenuButton.setEnabled(false, animated: true)
        
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
        colorSchemeReviewsButton.primaryColor = UIColor(red: CGFloat(0xc4) / 255.0,
                                                        green: CGFloat(0xe0) / 255.0,
                                                        blue: CGFloat(0xe9) / 255.0,
                                                        alpha: 1)
//            UIColor(red: CGFloat(0x1a) / 255.0,
//                                                     green: CGFloat(0x2a) / 255.0,
//                                                     blue: CGFloat(0x6c) / 255.0,
//                                                     alpha: 1)
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
        //            UIColor(red: CGFloat(0x1a) / 255.0,
        //                                                     green: CGFloat(0x2a) / 255.0,
        //                                                     blue: CGFloat(0x6c) / 255.0,
        //                                                     alpha: 1)

        colorSchemePhotos.primaryColor = UIColor(red: CGFloat(0x1a) / 255.0,green: CGFloat(0x2a) / 255.0,blue: CGFloat(0x6c) / 255.0,alpha: 1)
//            UIColor(red: CGFloat(0x06) / 255.0,
//                                           green: CGFloat(0xbe) / 255.0,
//                                           blue: CGFloat(0xb6) / 255.0,
//                                           alpha: 1)
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
        showReviewsButton.setTitleColor(UIColor.black, for: .normal)

        updateLayout()
        MDCCardsColorThemer.applySemanticColorScheme(colorSchemePhotos, to: card)
        
        showMenuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        showMoreButton.addTarget(self, action: #selector(showMoreImages), for: .touchUpInside)
        showReviewsButton.addTarget(self, action: #selector(showReviews), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func showMenu(){
        self.delegate!.didTapMenu()
    }
    @objc func showMoreImages(){
        self.delegate!.didTapPhotos()
    }
    @objc func showReviews(){
        self.delegate!.didTapReviews()
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

class ReviewDisplayView : UIView{
    let reviewList : [ReviewModel]
    
    init(frame: CGRect, reviewsToDisplay: [ReviewModel]) {
        reviewList = reviewsToDisplay
        super.init(frame: frame)
        
        if !self.frame.equalTo(CGRect.zero) {
            var currHeight = CGFloat.init(0);
            
            for review in reviewList{
                let reviewView = ReviewView.init(frame: CGRect.init(x: CGFloat.init(0), y: currHeight, width: self.frame.width, height: (self.frame.height/CGFloat.init(reviewList.count)) - 2.0 ), reviewToDisplay: review)
                currHeight = currHeight + reviewView.frame.height + 6.0
                self.addSubview(reviewView)
                
            }
            
//            if(currHeight > self.frame.height){
//                self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: currHeight)
//            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        var yPos = CGFloat.init(0);
//        for review in reviewList{
//            let reviewView = ReviewView.init(frame: CGRect.init(x: CGFloat.init(0), y: yPos, width: self.frame.width, height: self.frame.height/CGFloat.init(reviewList.count) ), reviewToDisplay: review)
//            
//            self.addSubview(reviewView)
//            yPos = yPos + self.frame.height/CGFloat.init(reviewList.count)
//        }
//    }
}

class ReviewView: UIView {
    let review : ReviewModel
    private var userLabel : UILabel = UILabel()
    private var ratingLabel : UILabel = UILabel()
    private var reviewTextView : UITextView = UITextView()
    
    init(frame: CGRect, reviewToDisplay: ReviewModel) {
         review = reviewToDisplay
        super.init(frame: frame)
//        self.layer.borderWidth = 0.1
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true;
        self.backgroundColor = UIColor(red: CGFloat(0xc4) / 255.0,
                                       green: CGFloat(0xe0) / 255.0,
                                       blue: CGFloat(0xe9) / 255.0,
                                       alpha: 1)
        
        //Set text
        userLabel.text = review.user.name
        ratingLabel.text = "Rating: " + review.ratingGiven.description + "/5"
        reviewTextView.text = review.reviewText
        
        //Set Style
        userLabel.font = UIFont.init(name: "Baskerville-SemiBold", size: 15)
        ratingLabel.font = UIFont.init(name: "Baskerville-SemiBold", size: 15)
        reviewTextView.font = UIFont.init(name: "Cochin", size: 11)
        reviewTextView.backgroundColor = UIColor.clear
        reviewTextView.isEditable = false
        reviewTextView.isScrollEnabled = true
        reviewTextView.clipsToBounds = false
        
        //Set frame
        userLabel.sizeToFit()
        userLabel.frame = CGRect.init(x: 3, y: 3, width: userLabel.frame.width, height: userLabel.frame.height)
        
        ratingLabel.sizeToFit()
        ratingLabel.frame = CGRect.init(x: self.frame.width - ratingLabel.frame.width - 4.0, y: 3, width: ratingLabel.frame.width, height: ratingLabel.frame.height)
        
        reviewTextView.sizeToFit()
        let yPos = userLabel.frame.height > ratingLabel.frame.height ? userLabel.frame.height : ratingLabel.frame.height
//        let width = reviewTextView.frame.width > self.frame.width ? self.frame.width : reviewTextView.frame.width
//        let height = yPos + reviewTextView.frame.height > self.frame.height ? self.frame.height - yPos : reviewTextView.frame.height
        reviewTextView.frame = CGRect.init(x: 3, y: yPos + 6.0, width: self.frame.width-6, height: self.frame.height - (yPos+6))
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
                    self.addSubview(userLabel)
        self.addSubview(ratingLabel)
         self.addSubview(reviewTextView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        self.reviewTextView.setContentOffset(CGPoint.zero, animated: false)
    }
//    override func layoutSubviews() {
//        if !self.subviews.contains(userLabel){
//            self.addSubview(userLabel)
//        }
//        if !self.subviews.contains(ratingLabel){
//            self.addSubview(ratingLabel)
//        }
//        if !self.subviews.contains(reviewTextView){
//            self.addSubview(reviewTextView)
//        }
//    }
    
    
}
