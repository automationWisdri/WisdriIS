//
//  TaskStateCell.swift
//  WisdriIS
//
//  Created by Allen on 5/5/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskStateCell: UITableViewCell {

    @IBOutlet weak var statusNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var startTimeLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var endTimeLabelLeadingConstraint: NSLayoutConstraint!
    
    let timeLabelTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(12)]
    
    let timeLabelWidth: CGFloat = 121
    
    let timeLabelLeadingBase: CGFloat = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(status: WISMaintenanceTaskState) {
        userNameLabel.text = status.personInCharge.roleName + ": " + status.personInCharge.fullName
        statusNameLabel.text = status.state
        startTimeLabel.text = WISConfig.DATE.stringFromDate(status.startTime) + " 起"
        endTimeLabel.text = WISConfig.DATE.stringFromDate(status.endTime) + " 止"
        
        if let string = startTimeLabel.text {
            self.startTimeLabelLeadingConstraint.constant = calculateOffset(string)
        }
//        if let string = endTimeLabel.text {
//            self.endTimeLabelLeadingConstraint.constant = calculateOffset(string)
//        }
    }
    
    func calculateOffset(string: String) -> CGFloat {
        
        let rect = string.boundingRectWithSize(CGSize(width: CGFloat(FLT_MAX), height: 18), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: timeLabelTextAttributes, context: nil)
        
        let offset = timeLabelWidth - rect.width
        
        let leadingConstraint = timeLabelLeadingBase - offset
        
        return leadingConstraint
        
    }
    
}
