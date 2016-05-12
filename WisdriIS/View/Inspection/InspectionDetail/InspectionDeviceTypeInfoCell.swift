//
//  InspectionDetailEquipTypeInfoCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionDeviceTypeInfoCell:InspectionDetailViewBaseCell {
    
    @IBOutlet weak var deviceTypeNameTitleLabel: UILabel!
    @IBOutlet weak var insepctionCycleTitleLabel: UILabel!
    @IBOutlet weak var deviceTypeNameLabel: UILabel!
    @IBOutlet weak var insepctionCycleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deviceTypeNameTitleLabel.text = NSLocalizedString("Device Type", comment: "") + ":"
        insepctionCycleTitleLabel.text = NSLocalizedString("Inspection Cycle", comment: "") + ":"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func bindData(model: WISInspectionTask) {
        deviceTypeNameLabel.text = model.device.deviceType.deviceTypeName
        insepctionCycleLabel.text = model.device.deviceType.inspectionCycleDescription()
    }
}