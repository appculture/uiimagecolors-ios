//
//  Store.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class Store: NSObject {

    var id = ""
    var name = ""
    var channelName = ""
    var address = ""
    var zip = ""
    var city = ""
    var phone = ""
    var fax = ""
    var longitude = 0.0
    var latitude = 0.0
    var email = ""
    var managerDE = ""
    var managerFR = ""
    var managerEN = ""
    var images = [ImageModel]()
    var shopClosed = ""
    var openingTimes = [DayModel]()
    var holidays = [DayModel]()
    
    init(with json: [String : AnyObject]) {
        
        guard
            let idString = json["id"],
            let nameString = json["name"],
            let channelNameString = json["channelName"],
            let addressString = json["address"],
            let zipString = json["zip"],
            let cityString = json["city"],
            let phoneString = json["phone"],
            let faxString = json["fax"],
            let longitudeVal = json["longitude"],
            let latitudeVal = json["latitude"],
            let emailString = json["email"],
            let managerDEString = json["manager"]?["de"],
            let managerFRString = json["manager"]?["fr"],
            let managerENString = json["manager"]?["en"],
            let imagesArray = json["images"],
            let shopClosedString = json["shopClosed"],
            let openingTimesArray = json["openingTimes"],
            let holidaysArray = json["holidays"]
            else {
                return
        }
        id = idString as! String
        name = nameString as! String
        channelName = channelNameString as!String
        address = addressString as! String
        zip = zipString as! String
        city = cityString as! String
        phone = phoneString as! String
        fax = faxString as! String
        longitude = longitudeVal as! Double
        latitude = latitudeVal as! Double
        email = emailString as! String
        managerDE = managerDEString as! String
        managerFR = managerFRString as! String
        managerEN = managerENString as! String
        images = ImageModel.initWithArray(imagesArray: imagesArray as! [[String : AnyObject]])
        shopClosed = shopClosedString as! String
        openingTimes = DayModel.initWithArray(daysArray: openingTimesArray as! [[String : AnyObject]])
        holidays = DayModel.initWithArray(daysArray: holidaysArray as! [[String : AnyObject]])
    }
    
    
}
