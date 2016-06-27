//
//  ClockInfoCell.swift
//  WisdriIS
//
//  Created by Allen on 5/9/16.
//  Copyright © 2016 Wisdri. All rights reserved.
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
    
    func bind(record: WISClockRecord) {
        
        infoLabel.text = record.clockActionTime.toDateTimeString()
        
        switch record.clockAction {
        case .In:
            clockImageView.image = UIImage(named: "icon_clock_active")
            annotationLabel.text = NSLocalizedString("Clock in")
        case .Off:
            clockImageView.image = UIImage(named: "icon_clock")
            annotationLabel.text = NSLocalizedString("Clock out")
        default:
            clockImageView.image = UIImage(named: "icon_fault")
            annotationLabel.text = NSLocalizedString("Undefined")
        }
    }
    
}
