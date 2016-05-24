//
//  InspectionResultShowSelectionCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/18/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionResultShowSelectionCell:InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 45.0
    
    @IBOutlet weak var inspectionShowResultSelectionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask) {
        switch model.inspectionResult {
        case .DeviceNormal:
            inspectionShowResultSelectionLabel.text = NSLocalizedString("Inspection Result", comment:"") + "  " + NSLocalizedString("Normal", comment: "")
        case .DeviceFaultForHandle:
            inspectionShowResultSelectionLabel.text = NSLocalizedString("Inspection Result", comment:"") + "  " + NSLocalizedString("Fault for Handle", comment: "")
        case .NotSelected:
            inspectionShowResultSelectionLabel.text = NSLocalizedString("Inspection Result", comment:"") + ": " + NSLocalizedString("None", comment: "")
        }
    }
}
