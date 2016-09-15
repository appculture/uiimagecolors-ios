//
//  StoreDetailsTableViewCell.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/15/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class StoreDetailsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(indexPath: IndexPath) {
       
        if (indexPath.section == 1 && indexPath.row == 0) {
            selectionStyle = UITableViewCellSelectionStyle.none
        }
        else {
            selectionStyle = UITableViewCellSelectionStyle.default
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            accessoryType = .disclosureIndicator
        }
        else {
            accessoryType = .none
        }
    }
    
    func updateStoreInfoDetails(storeDetailsArray: [[String : String]], row: Int) {
        let itemDetail:[String : String] = storeDetailsArray[row]
        textLabel?.text = itemDetail["title"]
        detailTextLabel?.numberOfLines = 2
        detailTextLabel?.text = itemDetail["detail"]
    }
    
    func updateStoreOpeningHours(daysNamesArray: [String], store: Store) {
        detailTextLabel?.numberOfLines = 0
        textLabel?.numberOfLines = 0
        let daysArray = store.openingTimes 
        
        var titleString = ""
        var detailString = ""
        
        for day in daysArray {
            if day.hours == "00:00 - 00:00" {
                detailString += "Geschlossen\n"
            }
            else {
                detailString += "\(day.hours)\n"
            }
        }
        
        for dayName in daysNamesArray {
            titleString += "\(dayName)\n"
        }
        textLabel?.text = titleString
        detailTextLabel?.text = detailString
    }
    
    func updateTitle(title: String) {
        textLabel?.text = title
    }
    
}
