//
//  MainViewController.swift
//  Globus
//
//  Created by Marko Tadic on 8/2/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showInto()
    }
    
    func configureUI() {
        configureBackgroundColor()
        configureTextView()
        view.addSubview(textView)
    }
    
    func configureTextView() {
        textView.frame = view.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.textContainerInset = UIEdgeInsets(top: 20.0, left: 8.0, bottom: 20.0, right: 0.8)
        textView.isEditable = false
        textView.alwaysBounceVertical = true
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 16.0)
    }
    
    func configureBackgroundColor() {
        switch UIApplication.buildConfiguration.environment {
        case .Develop:
            view.backgroundColor = UIColor.blue
        case .Stage:
            view.backgroundColor = UIColor.orange
        case .Production:
            view.backgroundColor = UIColor.green
        default:
            view.backgroundColor = UIColor.white
        }
    }
    
    func configureData() {
        textView.text = UIApplication.appInfo
    }
    
    func showInto() {
        performSegue(withIdentifier: "showIntro", sender: nil)
    }
}

extension UIApplication {
    
    class var appInfo: String {
        var infoString = ""
        infoString += "Bundle Name:\n\(UIApplication.appBundleDisplayName)\n\n"
        infoString += "App Version:\n\(UIApplication.appVersionBuild)\n\n"
        infoString += "Build Configuration:\n\(UIApplication.appConfiguration)\n\n"
        infoString += "Bundle ID:\n\(UIApplication.appBundleID)\n\n"
        infoString += "Backend URL:\n\(UIApplication.backendURL)\n\n"
        return infoString
    }
    
}
