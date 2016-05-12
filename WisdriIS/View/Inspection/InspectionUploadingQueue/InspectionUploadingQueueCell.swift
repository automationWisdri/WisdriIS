//
//  InspectionListCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/13/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionUploadingQueueCell: UITableViewCell {
    
    @IBOutlet weak var inspectionDeviceNameLabel: UILabel!
    @IBOutlet weak var inspectionDeviceTypeNameLabel: UILabel!
    @IBOutlet weak var inspectionUploadingStateLabel: UILabel!
    @IBOutlet weak var inspectionFinishedTimeLabel: UILabel!
    @IBOutlet weak var imageUploadingProgressLabel: UILabel!
    @IBOutlet weak var imageUploadingProgressView: UIProgressView!
    @IBOutlet weak var inspectionResultLabel: UILabel!
    
    var inspectionDeviceID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageUploadingProgressView.transform = CGAffineTransformMakeScale(1.0, 3.0)
        imageUploadingProgressView.progressViewStyle = .Default
        // imageUploadingProgressView.progressTintColor = UIColor.blueColor()
        imageUploadingProgressView.backgroundColor = UIColor.clearColor()
        
        imageUploadingProgressView.trackTintColor=UIColor.clearColor()
        
        imageUploadingProgressView.layer.cornerRadius = 3
        imageUploadingProgressView.layer.masksToBounds = true
        imageUploadingProgressView.layer.borderWidth = 0.3
        imageUploadingProgressView.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(model: InspectionTaskForUploading) {
        self.inspectionDeviceNameLabel.text = model.inspectionTask.device.deviceName
        self.inspectionDeviceTypeNameLabel.text = model.inspectionTask.device.deviceType.deviceTypeName
        self.inspectionUploadingStateLabel.text = NSLocalizedString(model.uploadingState.rawValue, comment: "")
        self.inspectionFinishedTimeLabel.text = NSLocalizedString("Finished Time: ", comment: "") + model.inspectionTask.inspectionFinishedTime.toDateTimeString()
        
        if model.inspectionTask.inspectionResult == .DeviceFaultForHandle {
            self.inspectionResultLabel.textColor = UIColor.redColor()
            self.inspectionResultLabel.text = NSLocalizedString("Fault for Handle")
        } else {
            self.inspectionResultLabel.textColor = UIColor.darkGrayColor()
            self.inspectionResultLabel.text = NSLocalizedString("Normal")
        }
        
        let imageUploadingProgressLabelisHidden = (model.uploadingState == .UploadingImages) ? false : true
        self.imageUploadingProgressLabel.hidden = imageUploadingProgressLabelisHidden
        self.imageUploadingProgressView.hidden = imageUploadingProgressLabelisHidden
        if model.uploadingState == .UploadingImages {
            let fraction = Float(model.imageUploadingProgress.fractionCompleted)
            let percentage = fraction * 100
            self.imageUploadingProgressView.setProgress(fraction, animated: true)
            self.imageUploadingProgressLabel.text = String(format: "%.2f", percentage) + "%"
            print("Percentage: \(self.imageUploadingProgressLabel.text)")
            
        } else {
            self.imageUploadingProgressLabel.text = "0.0%"
        }
        
        self.inspectionDeviceID = model.inspectionTask.device.deviceID
    }
}