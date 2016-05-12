//
//  ContactsCell.swift
//  WisdriIS
//
//  Created by Allen on 3/3/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var badgeImageView: UIImageView!
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

    func configureWithDiscoveredUser(tableView: UITableView, indexPath: NSIndexPath) {

//        let plainAvatar = PlainAvatar(avatarURLString: discoveredUser.avatarURLString, avatarStyle: miniAvatarStyle)
//        avatarImageView.navi_setAvatar(plainAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)

//        joinedDateLabel.text = discoveredUser.introduction
        avatarImageView.image = UIImage(named: "ic_face")
        joinedDateLabel.text = "维修工程师"


//        if let distance = discoveredUser.distance?.format(".1") {
//            lastTimeSeenLabel.text = "\(distance)km | \(NSDate(timeIntervalSince1970: discoveredUser.lastSignInUnixTime).timeAgo)"
//        } else {
//            lastTimeSeenLabel.text = "\(NSDate(timeIntervalSince1970: discoveredUser.lastSignInUnixTime).timeAgo)"
//        }
        
        lastTimeSeenLabel.text = "在线"

//        nameLabel.text = discoveredUser.nickname
        
        nameLabel.text = "任韬"

//        if let badgeName = discoveredUser.badge, badge = BadgeView.Badge(rawValue: badgeName) {
//            badgeImageView.image = badge.image
//            badgeImageView.tintColor = badge.color
//        } else {
//            badgeImageView.image = nil
//        }
    }
    
    func bind(wisUser: WISUser) {
        nameLabel.text = wisUser.fullName
        joinedDateLabel.text = wisUser.roleName
        lastTimeSeenLabel.text = "在线"
//        avatarImageView.image = wisUser.thumbnailPhoto
        avatarImageView.image = UIImage(named: "default_avatar_40")
    }
}
