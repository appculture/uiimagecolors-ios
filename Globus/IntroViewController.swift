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
        
        loginButton.titleLabel?.textAlignment = .center
        introList.text = "- Test1\n- Test2\n- Test3\n- Test4\n- Test5\n- Test6\n- Test7\n- Test8\n- Test9\n- Test10\n- Test11"
        loginButton.setTitle("Ich besitze bereits ein Konto oder eine Pluscard", for: .normal)
    }
    // Mark: - Actions

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
}
