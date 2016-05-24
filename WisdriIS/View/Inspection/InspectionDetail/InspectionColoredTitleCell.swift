//
//  InspectionSubmitButtonCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionColoredTitleCell: InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 60.0
    
    var coloredTitleColor: UIColor = UIColor.wisTintColor() {
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
