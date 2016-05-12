//
//  InspectionEquipBelongingCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionDeviceBelongingCell:InspectionDetailViewBaseCell {
    
    @IBOutlet weak var deviceCompanyLabel: UILabel!
    @IBOutlet weak var deviceProcessSegmentLabel: UILabel!
    
    @IBOutlet weak var deviceCompanyTitleLabel: UILabel!
    @IBOutlet weak var deviceProcessSegmentTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deviceCompanyTitleLabel.text = NSLocalizedString("Company", comment: "") + ":"
        deviceProcessSegmentTitleLabel.text = NSLocalizedString("Process Segment", comment: "") + ":"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func bindData(model: WISInspectionTask) {
        super.bindData(model)
        deviceCompanyLabel.text = model.device.company
        deviceProcessSegmentLabel.text = model.device.processSegment
    }
}

