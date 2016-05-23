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
    @IBOutlet weak var annotationInfoLabel: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var annotationImageView: UIImageView!
    
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

    
    @objc private func tapToCall(sender: UITapGestureRecognizer) {
        
        tapToCallAction?()
    }

}
