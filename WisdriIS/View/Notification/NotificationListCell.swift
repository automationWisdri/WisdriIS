//
//  NotificationListCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class NotificationListCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 90.0
    
    @IBOutlet weak var notificationContentTitleLabel: UILabel!
    @IBOutlet weak var notificationContentLabel: UILabel!
    @IBOutlet weak var notificationTaskIDTitleLabel: UILabel!
    @IBOutlet weak var notificationTaskIDLabel: UILabel!
    @IBOutlet weak var notificationReceivedDateTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(model: WISPushNotification) {
        self.notificationContentTitleLabel.text = NSLocalizedString("Notification Content", comment: "")
        self.notificationContentLabel.text = model.notificationContent
        self.notificationTaskIDTitleLabel.text = NSLocalizedString("Task ID", comment: "")
        self.notificationTaskIDLabel.text = model.notificationTaskID
        self.notificationReceivedDateTimeLabel.text = model.notificationReceivedDateTime.toDateTimeString()
    }
}
