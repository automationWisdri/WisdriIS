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
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskStatusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        taskDescriptionTextView.textContainer.lineFragmentPadding = 0
        taskDescriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskDescriptionTextView.textContainer.maximumNumberOfLines = 2
        taskDescriptionTextView.textContainer.lineBreakMode = .ByTruncatingTail
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(model: WISMaintenanceTask) {
        
        self.taskIDLabel?.text = model.taskID
        self.taskDateLabel?.text = WISConfig.DATE.stringFromDate(model.createdDateTime)
        self.taskDescriptionTextView.text = model.taskApplicationContent
//        taskDescriptionTextView.text = "asifjojrfeojrfpoekrfpoekrpgoepjgpejgpejrgpowkrpfokwpoefkwpoejfpowjefpwjefpwjepfojwpeofkpwoefpowjefpowjefpjwe"
        
        if model.state == "" {
            self.taskStatusImageView?.image = WISConfig.taskStateImage("未知状态")
            self.taskStatusLabel?.text = "未知状态"
        } else {
            self.taskStatusImageView?.image = WISConfig.taskStateImage(model.state)
            self.taskStatusLabel?.text = WISConfig.configureStateText(model.state)
        }
        
    }

}
