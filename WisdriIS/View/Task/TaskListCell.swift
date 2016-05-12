//
//  TaskListCell.swift
//  WisdriIS
//
//  Created by Allen on 3/17/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskListCell: UITableViewCell {

    @IBOutlet weak var taskIDLabel: UILabel!
    @IBOutlet weak var taskStatusLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskStatusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(model: WISMaintenanceTask) {
        
        self.taskIDLabel?.text = model.taskID
        self.taskDateLabel?.text = DATE.stringFromDate(model.createdDateTime)
//        self.taskDescriptionLabel?.text = model.taskApplicationContent
        taskDescriptionLabel.text = model.taskDescription
        
        if model.state == "" {
            self.taskStatusImageView?.image = taskStateImage("未知状态")
            self.taskStatusLabel?.text = "未知状态"
        } else {
            self.taskStatusImageView?.image = taskStateImage(model.state)
            self.taskStatusLabel?.text = configureStateText(model.state)
        }
        
    }

}
