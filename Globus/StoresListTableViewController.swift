//
//  StoresListTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/12/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit
import CoreLocation

class StoresListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var storesList = [Store]()
    var selectedStore: Store? = nil
    var locationManager: CLLocationManager!
    
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
        setupLocationService()
        
    }
    
    func sortStoresByLocation(with myLocation: CLLocation) {
            storesList.sort(by: { (store1: Store, store2: Store) -> Bool in
            let location1 = CLLocation(latitude: store1.latitude, longitude: store1.longitude)
            let location2 = CLLocation(latitude: store2.latitude, longitude: store2.longitude)
            let distance1 = location1.distance(from: myLocation)
            let distance2 = location2.distance(from: myLocation)
            
            if distance1 < distance2 {
                return true
            }
            return false
        })
        tableView.reloadData()
    }
    
    func setupLocationService() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
        }
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
    
    // Mark: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard
            let location = locations.last
        else {
            return
        }
        sortStoresByLocation(with: location)
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
