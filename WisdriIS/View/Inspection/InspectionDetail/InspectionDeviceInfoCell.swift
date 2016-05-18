//
//  InspectionEquipmentInfoCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionDeviceInfoCell:InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 70.0
    
    @IBOutlet weak var deviceNameTitleLabel: UILabel!
    @IBOutlet weak var deviceCodeTitleLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deviceNameTitleLabel.text = NSLocalizedString("Device Name", comment: "") + ":"
        deviceCodeTitleLabel.text = NSLocalizedString("Device Code", comment: "") + ":"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask) {
        deviceNameLabel.text = model.device.deviceName
        deviceCodeLabel.text = model.device.deviceCode
    }
}
