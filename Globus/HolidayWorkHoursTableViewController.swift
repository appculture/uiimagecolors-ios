//
//  HolidayWorkHoursTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/15/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class HolidayWorkHoursTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HolidayCell", for: indexPath)
        return cell
    }
    
}
