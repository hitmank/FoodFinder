//
//  FIlterPanel.swift
//  Food Explore
//
//  Created by Balakrishnan, Karan on 9/11/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit

class FilterPanel: UIView {
    var cuisine_list : [String] = []
    var subTableView : UITableView = UITableView.init()
    var isOpen = false
    let headerLabel : UILabel = UILabel.init()
    let isOpenLabel : UILabel = UILabel.init()
    let cuisineLabel : UILabel = UILabel.init()
    
    override func layoutSubviews() {
        headerLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: 100)
        headerLabel.text = "Filter By:"
        isOpenLabel.frame = CGRect.init(x: 0, y:headerLabel.frame.origin.y + headerLabel.frame.height , width: self.frame.width, height: 100)
        isOpenLabel.text = "Is open right now"
        cuisineLabel.frame = CGRect.init(x: 0, y: isOpenLabel.frame.origin.y + isOpenLabel.frame.height, width: self.frame.width, height: 100)
        cuisineLabel.text = "Cuisine"
        
        self.addSubview(headerLabel)
        self.addSubview(isOpenLabel)
        self.addSubview(cuisineLabel)
    }
}
