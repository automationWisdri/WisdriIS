//
//  InspectionEquipBelongingCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionDeviceBelongingCell:InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 70.0
    
    @IBOutlet weak var deviceCompanyLabel: UILabel!
    @IBOutlet weak var deviceProcessSegmentLabel: UILabel!
    
    @IBOutlet weak var deviceCompanyTitleLabel: UILabel!
    @IBOutlet weak var deviceProcessSegmentTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deviceCompanyTitleLabel.text = NSLocalizedString("Company", comment: "") //+ ":"
        deviceProcessSegmentTitleLabel.text = NSLocalizedString("Process Segment", comment: "") //+ ":"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask) {
        deviceCompanyLabel.text = model.device.company
        deviceProcessSegmentLabel.text = model.device.processSegment
    }
}

