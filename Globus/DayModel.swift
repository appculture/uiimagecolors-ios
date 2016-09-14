//
//  DayModel.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class DayModel {

    var weekday = 0
    var hours = ""
    
    init(with json: [String : AnyObject]) {
        
        guard
            let weekdayVal = json["weekday"],
            let hoursString = json["hours"]
            else {
                return
        }
        weekday = weekdayVal as! Int
        hours = hoursString as! String
    }
    
   static func initWithArray(daysArray: [[String : AnyObject]]) -> [DayModel] {
        var parsedArray = Array<DayModel>()
        for dayItem in daysArray {
            let tempDayItem = DayModel(with: dayItem)
            parsedArray.append(tempDayItem)
        }
        return parsedArray
    }
}
