//
//  KerningdatelistLabel.swift
//  Umbrella
//
//  Created by 山下幸助 on 2023/06/30.
//

import UIKit
@IBDesignable

class KerningdatelistLabel: UILabel {
    @IBInspectable var kerning: CGFloat = 0.0 {
        didSet {
            if let attributedText = self.attributedText {
                let attribString = NSMutableAttributedString(attributedString: attributedText)
                attribString.addAttributes([.kern: kerning], range: NSRange(location: 0, length: attributedText.length))
                self.attributedText = attribString
            }
        }
    }

}
