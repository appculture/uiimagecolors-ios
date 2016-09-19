//
//  VoucherListTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/16/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class VoucherListTableViewController: UITableViewController {

    var promoArray = [[String : AnyObject]]()
    var bonusArray = [[String : AnyObject]]()
    var usedArray = [[String : AnyObject]]()
    var favoritesArray = [[String : AnyObject]]()
    var sectionTitles = [String]()
    var voucherArray = [[String : AnyObject]]()

    @IBOutlet weak var barCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if favoritesArray.count == 0 {
            sectionTitles = ["Promo", "Bonus", "Used"]
        }
        else {
            sectionTitles = ["Favorites", "Promo", "Bonus", "Used"]
        }
        getVoucherList()
    }
    
    func getVoucherList() {
        
        guard
            let storesFilePath = Bundle.main.path(forResource: "Vouchers", ofType: "json")
            else {
                print("No File at location")
                return
        }
        let tempDictionary = NSDictionary(contentsOfFile: storesFilePath) as? [String : AnyObject]
        print("Voucher list : \(tempDictionary)")
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return favoritesArray.count
        case 1:
            return promoArray.count
        case 2:
            return bonusArray.count
        case 3:
            return usedArray.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell", for: indexPath)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
