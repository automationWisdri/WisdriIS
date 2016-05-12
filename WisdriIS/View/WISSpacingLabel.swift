//
//  WISSpacingLabel.swift
//  WisdriIS
//
//  Created by Allen on 1/11/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class WISSpacingLabel: UILabel {
    var spacing :CGFloat = 3.0
    override var text: String?{
        set{
            if newValue?.Length > 0 {
                let attributedString = NSMutableAttributedString(string: newValue!);
                let paragraphStyle = NSMutableParagraphStyle();
                paragraphStyle.lineBreakMode=NSLineBreakMode.ByTruncatingTail;
                paragraphStyle.lineSpacing=self.spacing;
                paragraphStyle.alignment=self.textAlignment;
                attributedString.addAttributes(
                    [
                        NSParagraphStyleAttributeName:paragraphStyle
                    ],
                    range: NSMakeRange(0, newValue!.Length));
                super.attributedText = attributedString;
            }
        }
        get{
            return super.text;
        }
    }
}
