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

    }

    
    func showInto() {
        performSegue(withIdentifier: "showIntro", sender: nil)
    }
    
    func showTabController() {
        performSegue(withIdentifier: "showTabController", sender: nil)
    }
    
    // Mark: - Actions
    
    @IBAction func uregisteredButtonTapped(_ sender: UIButton) {
        showInto()
    }
    
    @IBAction func registeredButtonTapped(_ sender: UIButton) {
        showTabController()
    }
    
}
