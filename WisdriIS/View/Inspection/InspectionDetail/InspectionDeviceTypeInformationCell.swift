//
//  InspectionEquipTypeDescriptionCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionDeviceTypeInformationCell:InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 120.0
    
    @IBOutlet weak var deviceTypeInformationTitleLabel: UILabel!
    @IBOutlet weak var deviceTypeInformationTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deviceTypeInformationTitleLabel.text = NSLocalizedString("Inspection Info", comment: "")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask) {
        deviceTypeInformationTextView.text = model.device.deviceType.inspectionInformation
    }
}