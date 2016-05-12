//
//  InspectionEquipRemarkCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionDeviceRemarkCell:InspectionDetailViewBaseCell {
    
    @IBOutlet weak var deviceRemarkTitleLabel: UILabel!
    @IBOutlet weak var deviceRemarkTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deviceRemarkTitleLabel.text = NSLocalizedString("Remark", comment: "")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func bindData(model: WISInspectionTask) {
        deviceRemarkTextView.text = model.device.remark
    }
}