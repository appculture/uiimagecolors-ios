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
    
    func configureCell() {
        openingHoursLabel.text = "Heute: 9:00 - 20:00"
        adressLabel.text = "Globus Zurich Bellevue \nTheatreStrasse 12 \n8001 Zurich"
    }

}
