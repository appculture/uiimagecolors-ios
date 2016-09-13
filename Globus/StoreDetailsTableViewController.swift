//
//  StoreDetailsTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class StoreDetailsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
