//
//  StoresListTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/12/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class StoresListTableViewController: UITableViewController {
    
    var storesList = [Store]()
    var selectedStore: Store? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStoreList()
    }
    
    func getStoreList() {
        
        guard
            let storesFilePath = Bundle.main.path(forResource: "StoresList", ofType: "plist")
        else {
            print("No File at location")
            return
        }
        let tempDictionary = NSDictionary(contentsOfFile: storesFilePath) as? [String : AnyObject]
        guard
            let storesArray = tempDictionary?["result"]?["stores"]
            else {
                print("No Array Data")
                return
        }
        storesList = Store.initWithArray(storesArray: storesArray as! [[String : AnyObject]])
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreTableViewCell
        let store = storesList[indexPath.row] as Store
        cell.configureCell(withStore: store)
        return cell
    }
    
    // Mark: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStore = storesList[indexPath.row] as Store
        performSegue(withIdentifier: "StoreDetailsSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Mark: - Actions
    
    @IBAction func globusOnlineTapped(_ sender: UIButton) {
        let globusURL = URL(string: "https://www.globus.ch/")
        UIApplication.shared.openURL(globusURL!)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! StoreDetailsTableViewController
        destination.store = selectedStore
    }

}
