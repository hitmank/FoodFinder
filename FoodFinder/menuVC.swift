//
//  menuVC.swift
//  FoodFinder
//
//  Created by Karan Balakrishnan on 8/7/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit
import StarWars
import ElasticTransition

class MenuVC : ElasticModalViewController{
    var delegate: actionDelegate? = nil
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.red;
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(add)))
        self.modalTransition.edge = .right
        self.modalTransition.radiusFactor = 0.7
//        self.transitioningDelegate = self
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
}
