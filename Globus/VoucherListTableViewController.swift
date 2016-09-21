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
        
        getVoucherList()
    }
    
    func getVoucherList() {
        
        guard
            let storesFilePath = Bundle.main.path(forResource: "Vouchers", ofType: "plist")
            else {
                print("No File at location")
                return
        }
        let tempDictionary = NSDictionary(contentsOfFile: storesFilePath) as? [String : AnyObject]
        print("Voucher list : \(tempDictionary)")
        
        guard
        let voucherItems = tempDictionary?["vouchers"]
        else {
            return
        }
        for voucherItem in voucherItems as! [[String : AnyObject]] {
            let sectionTitle = voucherItem["title"] as! String
            sectionTitles.append(sectionTitle)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 4
        case 2:
            return 4
        case 3:
            return 4
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 45)
        let labelFrame = CGRect(x: 16, y: 0, width: view.bounds.width - 32, height: 45)
        let headerView = UIView(frame: headerFrame)
        headerView.backgroundColor = .black
        let titleLabel = UILabel(frame: labelFrame)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .white
        let titleString = sectionTitles[section]
        titleLabel.text = titleString
        headerView.addSubview(titleLabel)
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showVoucherDetails", sender: self)
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
