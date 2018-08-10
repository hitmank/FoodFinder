//
//  menuVC.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/7/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit

class MenuVC : UIViewController{
    var delegate: actionDelegate? = nil
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.red;
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(add)))
        
    }
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return StarWarsGLAnimator()
//    }
    @objc func add(){
        UIView.animate(withDuration: 1.0, animations: {
            
            self.view.backgroundColor = UIColor.clear
            
            self.delegate!.didTapMenu1()
        })
        
    }
    
}

protocol actionDelegate {
    func didTapMenu();
    func didTapMenu1();
    func didTapPhotos();
}
