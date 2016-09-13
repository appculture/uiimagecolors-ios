//
//  IntroViewController.swift
//  Globus
//
//  Created by Patrik Oprandi on 09/09/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var introList: UITextView!
    @IBOutlet weak var introImage: UIImageView!
    @IBOutlet weak var letsGoButton: UIButton!
    @IBOutlet weak var loginButton: UnderlineTextButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        introList.text = NSLocalizedString("Intro.Text", comment: "")
        
        letsGoButton.setTitle(NSLocalizedString("Intro.LetsGoButton", comment: ""), for: .normal)
        
        loginButton.setTitle(NSLocalizedString("Intro.LoginButton", comment: ""), for: .normal)
        loginButton.titleLabel?.textAlignment = .center
    }
    // Mark: - Actions

    @IBAction func loginButtonTaped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
    @IBAction func letsGoButtonTaped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LetsGoSegue", sender: self)
    }
}
