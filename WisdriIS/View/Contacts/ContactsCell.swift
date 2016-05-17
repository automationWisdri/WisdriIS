//
//  ContactsCell.swift
//  WisdriIS
//
//  Created by Allen on 3/3/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Navi

class ContactsCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var lastTimeSeenLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func bind(wisUser: WISUser) {
        nameLabel.text = wisUser.fullName
        joinedDateLabel.text = wisUser.roleName
//        lastTimeSeenLabel.text = "在线"
        lastTimeSeenLabel.hidden = true
        
        let avatarSize: CGFloat = 60.0
        
        var imagesInfo = [String : WISFileInfo]()
        
        guard wisUser.imagesInfo.count > 0 else {
            self.avatarImageView.image = UIImage(named: "default_avatar_40")
            return
        }
        
        for item : AnyObject in wisUser.imagesInfo.allKeys {
            imagesInfo[item as! String] = wisUser.imagesInfo.objectForKey(item) as? WISFileInfo
        }
        
        WISDataManager.sharedInstance().obtainImageOfUserWithUserName(wisUser.userName, imagesInfo: imagesInfo, downloadProgressIndicator: { progress in
            
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
                        self.avatarImageView.image = UIImage(named: "default_avatar_40")
                    }
                    }, completion: { _ in
                        
                })
                
            } else {
                self.avatarImageView.image = UIImage(named: "default_avatar_40")
            }
        }
    }
}
