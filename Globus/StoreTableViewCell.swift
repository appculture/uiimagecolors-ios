//
//  StoreTableViewCell.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/12/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageview: UIImageView!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(withStore store: Store) {
        setBackgroundImage(withStore: store)
        setWorkingHours(withStore: store)
        setAddressLabel(withStore: store)
    }
    
    func setBackgroundImage(withStore store: Store) {
        
    }

    func setWorkingHours(withStore store: Store) {
        let currentWeekDay = getCurrentDayOfWeek()
        var openingTimeString = ""
        let openingTimesArray = store.openingTimes
        for dayItem in openingTimesArray {
            if dayItem.weekday == currentWeekDay {
                openingTimeString = dayItem.hours
            }
        }
        if openingTimeString == "00:00 - 00:00" {
            openingHoursLabel.text = "Heute: Geschlossen"
        }
        else{
            openingHoursLabel.text = "Heute: \(openingTimeString)"
        }
        
    }
    
    func getCurrentDayOfWeek() -> Int? {
        let todayDate = Date()
        var myCalendar = Calendar(identifier: .gregorian)
        myCalendar.firstWeekday = 0
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    func setAddressLabel(withStore store: Store ) {
        let storeName = store.name
        let storeAddress = store.address
        let storeZip  = "\(store.zip)"
        let storeCity = store.city
        adressLabel.text = "\(storeName) \n\(storeAddress) \n\(storeZip) \(storeCity)"
    }
    
}
