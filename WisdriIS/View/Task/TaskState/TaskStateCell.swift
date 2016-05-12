//
//  TaskStateCell.swift
//  WisdriIS
//
//  Created by 任韬 on 16/5/6.
//  Copyright © 2016年 Wisdri. All rights reserved.
//

import UIKit

class TaskStateCell: UITableViewCell {

    @IBOutlet weak var statusNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
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
    }
    
}
