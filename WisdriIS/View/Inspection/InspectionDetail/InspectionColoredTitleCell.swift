//
//  InspectionSubmitButtonCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionColoredTitleCell: InspectionDetailViewBaseCell {
    
    var coloredTitleColor: UIColor = UIColor.blueColor() {
        willSet {
            coloredTitleLabel.textColor = newValue
        }
    }
    
    @IBOutlet weak var coloredTitleLabel: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
