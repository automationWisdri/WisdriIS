//
//  ClockInfoCell.swift
//  WisdriIS
//
//  Created by 任韬 on 16/5/9.
//  Copyright © 2016年 Wisdri. All rights reserved.
//

import UIKit

class ClockInfoCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var clockImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
