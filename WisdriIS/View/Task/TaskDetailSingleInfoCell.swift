//
//  TaskDetailSingleInfoCell.swift
//  WisdriIS
//
//  Created by Allen on 3/3/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskDetailSingleInfoCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var annotatinoInfoLabel: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!

    private var phoneNumber: String?
    
    var tapToCallAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tapToCall = UITapGestureRecognizer(target: self, action: #selector(TaskDetailSingleInfoCell.tapToCall(_:)))
        actionImageView.userInteractionEnabled = true
        actionImageView.addGestureRecognizer(tapToCall)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getPhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    @objc private func tapToCall(sender: UITapGestureRecognizer) {
        
        print("tap")
//        if let _ = phoneNumber, phoneCallURL = NSURL(string: "tel://\(phoneNumber)") {
//            print(phoneCallURL)
//            UIApplication.sharedApplication().openURL(phoneCallURL)
        
//            YepAlert.confirmOrCancel(title: "", message: phoneNumber!, confirmTitle: "呼叫", cancelTitle: "取消", inViewController: nil, withConfirmAction: {
//                
//                }, cancelAction: {})
            
//        }
        tapToCallAction?()
    }

}
