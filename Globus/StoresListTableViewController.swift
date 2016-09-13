//
//  StoresListTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/12/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class StoresListTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreTableViewCell
        cell.configureCell()
        return cell
    }
    
    // Mark: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "StoreDetailsSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Mark: - Actions
    
    @IBAction func globusOnlineTapped(_ sender: UIButton) {
        let globusURL = URL(string: "https://www.globus.ch/")
        UIApplication.shared.openURL(globusURL!)
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
