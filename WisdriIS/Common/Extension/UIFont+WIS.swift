//
//  UIFont+WIS.swift
//  WisdriIS
//
//  Created by Allen on 5/13/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func chatTextFont() -> UIFont {
        return UIFont.systemFontOfSize(16)
    }
    
    class func barButtonFont() -> UIFont {
        return UIFont.systemFontOfSize(14)
    }

    class func navigationBarTitleFont() -> UIFont { // make sure it's the same as system use
        return UIFont.boldSystemFontOfSize(17)
    }

    class func textViewFont() -> UIFont {
        return UIFont.systemFontOfSize(14)
    }
}
