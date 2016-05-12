//
//  ProfileInfoCell.swift
//  WisdriIS
//
//  Created by Allen on 5/5/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class ProfileInfoCell: UITableViewCell {

    @IBOutlet weak var infoTextField: UITextField!
    @IBOutlet weak var annotationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
