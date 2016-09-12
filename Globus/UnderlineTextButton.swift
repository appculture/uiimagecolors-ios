//
//  UnderlineButton.swift
//  Globus
//
//  Created by Patrik Oprandi on 12/09/16.
//  Copyright © 2016 appculture. All rights reserved.
//

import UIKit

class UnderlineTextButton: UIButton {
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: .normal)
        setAttributedTitle(attributedString(), for: .normal)
    }
    
    private func attributedString() -> NSAttributedString? {
        let attributes = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 13.0),
            NSForegroundColorAttributeName : UIColor.black,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
            ] as [String : Any]
        let attributedString = NSAttributedString(string: self.currentTitle!, attributes: attributes)
        return attributedString
    }
}
