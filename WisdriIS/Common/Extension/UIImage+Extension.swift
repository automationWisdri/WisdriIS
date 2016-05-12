//
//  UIImage+Extension.swift
//  WisdriIS
//
//  Created by Allen on 2/20/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

extension UIImage {
    
    func roundedCornerImageWithCornerRadius(cornerRadius: CGFloat) -> UIImage {
        
        let w = self.size.width
        let h = self.size.height
        
        if cornerRadius < 0 {
            cornerRadius = 0
        }
        if cornerRadius > min(w, h) {
            cornerRadius = min(w,h)
        }
        
        let imageFrame = CGRectMake(0, 0, w, h)
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale)
        
        UIBezierPath(roundedRect: imageFrame, cornerRadius: cornerRadius).addClip()
        self.drawInRect(imageFrame)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
