//
//  StoreDetailsTableViewController.swift
//  Globus
//
//  Created by Igor Vojinovic on 9/13/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit
import MapKit

class StoreDetailsTableViewController: UITableViewController {

    var store: Store? = nil
    var storeDetailsArray = [[String : String]]()
    let dayNames = ["Montag", "Dienstag","Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    
    @IBOutlet weak var storeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if (store?.phone != "") {
            let phoneItem = ["title" : "Telefon", "detail" : store?.phone]
            storeDetailsArray.append(phoneItem as! [String : String])
        }
        
        if (store?.email != "") {
            let emailItem = ["title" : "E-Mail", "detail" : store?.email]
            storeDetailsArray.append(emailItem as! [String : String])
        }
        
        if (store?.address != "") {
        
            let address = store?.address
            let zip = store?.zip
            let city = store?.city
            let detailedAddress = "\(address!) \(zip!) \(city!)"
            let adressItem = ["title" : "Adresse", "detail" : detailedAddress]
            storeDetailsArray.append(adressItem)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 0) {
            return calculteCellHeight()
        }
        return 50.0
    }
    
    func calculteCellHeight() -> CGFloat {
        var cellHeight = 0.0
        guard
            let storeItem = store
        else {
            return 0.0
        }
        for _ in storeItem.openingTimes {
            cellHeight += 26
        }
        return CGFloat(cellHeight)
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
            return storeDetailsArray.count
        default:
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreDetailsCell",
                                                 for: indexPath) as! StoreDetailsTableViewCell
        guard let storeItem = store
            else {
                return cell
        }
        cell.configureCell(indexPath: indexPath)
        switch indexPath.section {
        case 0:
            cell.updateStoreInfoDetails(storeDetailsArray: storeDetailsArray, row: indexPath.row)
        default:
            switch indexPath.row {
            case 0:
                cell.updateStoreOpeningHours(daysNamesArray: dayNames, store: storeItem)
            default:
                cell.updateTitle(title: "Feiertage")
            }
        }
        
        return cell
    }
    
    // Mark: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                makeCall()
            case 1:
                sendEmail()
            case 2:
                showOnMap()
            default:
                break
            }
        default:
            switch indexPath.row {
            case 1:
                performSegue(withIdentifier: "", sender: self)
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func makeCall() {
        guard
            let storeItem = store
        else {
            return
        }
        if (storeItem.phone != "") {
            let phoneNumber = storeItem.phone.replacingOccurrences(of: " ", with: "")
            let url = URL(string: "tel://\(phoneNumber)")
            UIApplication.shared.openURL(url!)
        }
    }
    
    func sendEmail() {
        guard
            let storeItem = store
            else {
                return
        }
        if (storeItem.email != "") {
            let email = storeItem.email
            let url = URL(string: "mailto://\(email)")
            UIApplication.shared.openURL(url!)
        }
    }
    
    func showOnMap() {
        guard
            let storeItem = store
            else {
                return
        }
        let lat = storeItem.latitude
        let lon = storeItem.longitude
        let coordinates = CLLocationCoordinate2DMake(lat,lon)
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(storeItem.name)"
        mapItem.openInMaps(launchOptions: options)
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
