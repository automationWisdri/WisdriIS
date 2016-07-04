//
//  ShiftCell.swift
//  WisdriIS
//
//  Created by Allen on 6/22/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class ShiftCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func getAttendanceStatusText(status: AttendanceStatus) -> String {
        
        switch status {
        case .AttendanceAbnormal:
            return "打卡异常"
        case .AttendanceClocked:
            return "已打卡"
        case .AttendanceNormal:
            return "打卡正常"
        case .AttendanceNotClocked:
            return "未打卡"
        case .NoAttendanceRecord:
            return "无打卡记录"
        case .UndefinedAttendanceStatus:
            return "打卡错误"
        }
        
    }
    
    private func getAttendanceStatusImage(status: AttendanceStatus) -> UIImage {
        
        switch status {
        case .NoAttendanceRecord, .UndefinedAttendanceStatus, .AttendanceNotClocked, .AttendanceAbnormal:
            return UIImage(named: "dot_abnormal")!
        case .AttendanceClocked, .AttendanceNormal:
            return UIImage(named: "dot_normal")!
        }
    }
    
    func bind(record: WISAttendanceRecord) {
//        avatarImageView.image = record.staff.imagesInfo
        nameLabel.text = record.staff.fullName
        statusLabel.text = getAttendanceStatusText(record.attendanceStatus)
        statusImageView.image = getAttendanceStatusImage(record.attendanceStatus)
        
        let avatarSize: CGFloat = 22
        
        var imagesInfo = [String : WISFileInfo]()
        
        guard record.staff.imagesInfo.count > 0 else {
            self.avatarImageView.image = UIImage(named: "default_avatar_30")
            return
        }
        
        for item : AnyObject in record.staff.imagesInfo.allKeys {
            imagesInfo[item as! String] = record.staff.imagesInfo.objectForKey(item) as? WISFileInfo
        }
        
        WISDataManager.sharedInstance().obtainImageOfUserWithUserName(record.staff.userName, imagesInfo: imagesInfo, downloadProgressIndicator: { progress in
            
        }) { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                // 图片获取成功
                let imagesDictionary = data as! Dictionary<String, UIImage>
                
                UIView.transitionWithView(self.avatarImageView, duration: imageFadeTransitionDuration, options: .TransitionCrossDissolve, animations: {
                    if let avatarOriginalImage = imagesDictionary.first?.1,
                        let avatarResizeImage = avatarOriginalImage.navi_resizeToSize(CGSize(width: avatarSize, height: avatarSize), withInterpolationQuality: CGInterpolationQuality.Default),
                        let avatarRoundImage = avatarResizeImage.navi_roundWithCornerRadius(avatarSize * 0.5, borderWidth: 0) {
                        self.avatarImageView.image = avatarRoundImage
                    } else {
                        self.avatarImageView.image = UIImage(named: "default_avatar_30")
                    }
                    }, completion: { _ in
                        
                })
                
            } else {
                self.avatarImageView.image = UIImage(named: "default_avatar_30")
            }
        }
    }
    
}
