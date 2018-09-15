//
//  FIlterPanel.swift
//  Food Explore
//
//  Created by Balakrishnan, Karan on 9/11/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit

class FilterPanel: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cuisine_list.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = dequeueReusableCell(withIdentifier: "cell")
        if(cell == nil){
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = cuisine_list[indexPath.row]
        cell?.backgroundColor = UIColor.lightGray
        return cell!
    }
    
    var cuisine_list : [String] = []
    var subTableView : UITableView = UITableView.init()
    var isOpen = false
    let headerLabel : UILabel = UILabel.init()
    let isOpenLabel : UILabel = UILabel.init()
    let cuisineLabel : UILabel = UILabel.init()
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.lightGray
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.insert
    }
    
    
}
