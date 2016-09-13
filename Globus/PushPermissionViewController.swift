//
//  PushPermissionViewController.swift
//  Globus
//
//  Created by Patrik Oprandi on 12/09/16.
//  Copyright © 2016 appculture. All rights reserved.
//
import UIKit
import UserNotifications

class PushPermissionViewController: UIViewController {
    
    @IBOutlet weak var permissionButton: UIButton!
    @IBOutlet weak var laterButton: UnderlineTextButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        permissionButton.setTitle(NSLocalizedString("PushPermission.GetPermission.Button", comment: ""), for: .normal)
        permissionButton.titleLabel?.textAlignment = .center
        
        laterButton.setTitle(NSLocalizedString("PushPermission.Later.Button", comment: ""), for: .normal)
        
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func askPermission(sender: UIButton) {
        notificationPermission()
    }
    
    private final func notificationPermission() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                
                switch setttings.authorizationStatus {
                case .denied:
                    let alert = UIAlertController(title: "Push disabled", message: "Enable Push in settings", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        self.openAppSettings()
                    }))
                    self.present(alert, animated: true, completion: {
                        print("completion block")
                    })
                    break
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                        guard error == nil else {
                            print("User will not get reminders")
                            return
                        }
                        
                        if granted {
                            print("Got permissions")
                            // push to voucher screen
                        }
                        else {
                            print("User will not get reminders")
                        }
                    }
                    break
                case .authorized:
                    // do nothing
                    break
                }
            }
        }
        else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private final func openAppSettings() {
        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString) as! URL)
    }
}
