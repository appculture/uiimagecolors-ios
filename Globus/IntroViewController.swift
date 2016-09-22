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
        
        introList.layer.shadowColor = UIColor.black.cgColor
        introList.layer.shadowRadius = 0.8
        introList.layer.shadowOpacity = 0.75
        introList.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        letsGoButton.setTitle(NSLocalizedString("Intro.LetsGoButton", comment: ""), for: .normal)
        
        loginButton.setTitle(NSLocalizedString("Intro.LoginButton", comment: ""), for: .normal)
        loginButton.titleLabel?.textAlignment = .center
        
        let colors = introImage.image?.getColors()
        introList.textColor = colors?.secondaryColor
    }
    // Mark: - Actions

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
    @IBAction func letsGoButtonTaped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LetsGoSegue", sender: self)
    }
}
