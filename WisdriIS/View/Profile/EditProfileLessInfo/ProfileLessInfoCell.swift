//
//  ProfileLessInfoCell.swift
//  WisdriIS
//
//  Created by Allen on 4/27/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class ProfileLessInfoCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabelTrailingConstraint: NSLayoutConstraint!

    struct ConstraintConstant {
        static let minInfoLabelTrailing: CGFloat = 8
        static let normalInfoLabelTrailing: CGFloat = 8 + 30 + 8
    }

    @IBOutlet weak var badgeImageView: UIImageView!

    @IBOutlet weak var accessoryImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryImageView.tintColor = UIColor.wisCellAccessoryImageViewTintColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
