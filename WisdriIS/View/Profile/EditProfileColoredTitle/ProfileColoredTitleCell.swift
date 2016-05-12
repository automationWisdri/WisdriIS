//
//  ProfileColoredTitleCell.swift
//  WisdriIS
//
//  Created by Allen on 4/26/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class ProfileColoredTitleCell: UITableViewCell {

    var coloredTitleColor: UIColor = UIColor.redColor() {
        willSet {
            coloredTitleLabel.textColor = newValue
        }
    }

    @IBOutlet weak var coloredTitleLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
