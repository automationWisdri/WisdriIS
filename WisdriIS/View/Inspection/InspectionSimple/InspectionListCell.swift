//
//  InspectionListCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/13/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionListCell: UITableViewCell {
    
    @IBOutlet weak var inspectionDeviceImage: UIImageView!
    @IBOutlet weak var inspectionDeviceName: UILabel!
    @IBOutlet weak var inspectionDeviceTypeName: UILabel!
    @IBOutlet weak var inspectionDeviceProcessSegment: UILabel!
    @IBOutlet weak var inspectionExpirationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(model: WISInspectionTask, historicalInspection: Bool) {
        self.inspectionDeviceName.text = model.device.deviceName
        if historicalInspection {
            self.inspectionExpirationDate.text = NSLocalizedString("Finished Time", comment: "") + ": " + WISConfig.DATE.stringFromDate(model.inspectionFinishedTime)
        } else {
            self.inspectionExpirationDate.text = NSLocalizedString("Expiration Time", comment: "") + ": " + WISConfig.DATE.stringFromDate(model.lastInspectionFinishedTimePlusCycleTime)
        }
        self.inspectionDeviceTypeName.text = model.device.deviceType.deviceTypeName
        // self.taskStatusImageView?.image = WISConfig.taskStateImage(model.state)
        self.inspectionDeviceProcessSegment.text = model.device.processSegment
    }
}