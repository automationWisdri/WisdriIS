//
//  TaskListFilterButtonView.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 6/2/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit


class TaskListFilterButtonView: UIView {
    
    var viewHeight: CGFloat {
        return 60
    }
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        okButton.backgroundColor = UIColor.redColor()
        okButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        okButton.setTitle(NSLocalizedString("OK", comment: ""), forState: .Normal)
        okButton.autoresizingMask = .FlexibleWidth
        
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: .Normal)
        cancelButton.autoresizingMask = .FlexibleWidth
    }
    
    func layoutButton() {
        let frameWidth = self.frame.size.width
        okButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width / 2, self.viewHeight)
        cancelButton.frame = CGRectMake(0.0, self.frame.size.width / 2, self.frame.size.width / 2, self.viewHeight)
        
        print(okButton.frame)
        print(cancelButton.frame)
    }
    
}