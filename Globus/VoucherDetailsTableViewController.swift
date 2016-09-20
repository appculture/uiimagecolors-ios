//
//  VoucherDetailsTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/19/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class VoucherDetailsTableViewController: UITableViewController {
    
    var showBarcode = false

    @IBOutlet var promoLabel: UITableView!
    @IBOutlet var favoritesButton: UITableView!
    @IBOutlet weak var voucherImageView: UIImageView!
    @IBOutlet weak var discountValueLabel: UILabel!
    @IBOutlet weak var discountItemLabel: UILabel!
    @IBOutlet weak var validToLabel: UILabel!
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    func updateLabels() {
        discountItemLabel.text = " Rabatt auf das ganze Sortiment."
        disclaimerLabel.text = "Gegen Abgabe dieses Gutscheins werden Ihnen beim nächsten Einkauf 10.- Rabatt abgezogen. Keine Teilrückvergütung, Barauszahlung oder Verrechnung mit rückwirkenden Käufen möglich. Wird von allen Globus-, und Herren Globus-Filalen in Zahlung genommen."
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 200.0
        case 2:
            if (showBarcode == true) {
                return 0.0
            }
            else {
                return UITableViewAutomaticDimension
            }
        case 3:
            if (showBarcode == false) {
                return 0.0
            }
            else {
                return 75.0
            }
            
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 200.0
        case 1:
            return 180.0
        case 2:
            return 45.0
        case 3:
            return 55.0
        case 4:
            return 200.0
        default:
            return 55.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            useDiscountBarCode()
        default:
            return
        }
    }
    
    func  useDiscountBarCode() {
        showBarcode = true
        tableView.reloadData()
    }
    
}
