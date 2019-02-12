//
//  FIlterPanel.swift
//  Food Explore
//
//  Created by Balakrishnan, Karan on 9/11/18.
//  Copyright © 2018 Karan Balakrishnan. All rights reserved.
//

import Foundation
import UIKit

enum FilterType {
    case Cuisine
    case Price
    case Unknown
}

protocol filterSelectionDelegate {
    func didSelectFilterItem(item : String, of type: FilterType)
    func didDeSelectFilterItem(item : String, of type: FilterType)
}

/**
    This class encapsulates the tableView that displays the filters
    It is owned by the main ViewController.
    'filter_items' defines the list of cells for the tableView.
 */

class FilterPanel: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    /**
     Variables
     */
    var filter_items : [String] = []
    var selectionDelegate : filterSelectionDelegate? = nil
    var currentFilterType : FilterType = .Unknown
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.white
        
        /**
         For rounded edges
         */
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
    
    /**
     UITableView - Delegate/DataSource overrides
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filter_items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = dequeueReusableCell(withIdentifier: "cell")
        if(cell == nil){
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = filter_items[indexPath.row]
        cell?.backgroundColor = UIColor.white
        cell?.selectionStyle = UITableViewCellSelectionStyle.blue
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.insert
    }
    
    /**
     Table interaction
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did Select: \n");
        print(filter_items[indexPath.row]);
        let selectedItem = filter_items[indexPath.row]
        selectionDelegate?.didSelectFilterItem(item: selectedItem, of: currentFilterType)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Did Deselect: \n");
        print(filter_items[indexPath.row]);
        let deSelectedItem = filter_items[indexPath.row]
        selectionDelegate?.didDeSelectFilterItem(item: deSelectedItem, of: currentFilterType)
    }
    
}
