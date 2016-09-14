//
//  StoreDetailsTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class StoreDetailsTableViewController: UITableViewController {

    var store: Store? = nil
    
    @IBOutlet weak var storeImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 50.0
        default:
            return 30.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return viewForHeaderWith(height: 50.0, titleFontSize: 22.0, titleText: (store?.name)!)
        default:
            return viewForHeaderWith(height: 30.0, titleFontSize: 15.0, titleText: "Öffnungszeiten")
        }
    }
    
    func viewForHeaderWith(height: CGFloat, titleFontSize: CGFloat, titleText: String) -> UIView {
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height)
        let headerView = UIView(frame: frame)
        headerView.backgroundColor = UIColor.white
        frame.origin.x += 8
        let titleLabel = UILabel(frame: frame)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.black
        titleLabel.text = titleText
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        headerView.addSubview(titleLabel)
        return headerView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreDetailsCell", for: indexPath)
        if (indexPath.section == 1 && indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
        return cell
    }
    
    // Mark: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 0) {
            return 150 //must be custom height
        }
        return 50
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
