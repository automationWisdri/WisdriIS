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
    
    let timeLabelWidth: CGFloat = 106
    
    let timeLabelLeadingBase: CGFloat = -4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(status: WISMaintenanceTaskState) {
        userNameLabel.text = status.personInCharge.fullName
        statusNameLabel.text = status.state
        startTimeLabel.text = DATE.stringFromDate(status.startTime)
        endTimeLabel.text = DATE.stringFromDate(status.endTime)
        
        if let string = startTimeLabel.text {
            self.startTimeLabelLeadingConstraint.constant = calculateOffset(string)
        }
        if let string = endTimeLabel.text {
            self.endTimeLabelLeadingConstraint.constant = calculateOffset(string)
        }
    }
    
    func calculateOffset(string: String) -> CGFloat {
        
        let rect = string.boundingRectWithSize(CGSize(width: CGFloat(FLT_MAX), height: 18), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: timeLabelTextAttributes, context: nil)
        
        let offset = timeLabelWidth - rect.width
        
        let leadingConstraint = timeLabelLeadingBase - offset
        
        return leadingConstraint
        
    }
    
}
