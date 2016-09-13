//
//  ImageModel.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class ImageModel: NSObject {

    var type = ""
    var url = ""
    
    init(with json: [String : AnyObject]) {

            guard
                let typeString = json["type"],
                let urlString = json["url"]
            else {
                return
            }
            type = typeString as! String
            url = urlString as! String
    }
    
   static func initWithArray(imagesArray: [[String : AnyObject]]) -> [ImageModel] {
        var parsedArray = Array<ImageModel>()
        for imageItem in imagesArray {
            let tempImageItem = ImageModel(with: imageItem)
            parsedArray.append(tempImageItem)
        }
        return parsedArray
    }
}
