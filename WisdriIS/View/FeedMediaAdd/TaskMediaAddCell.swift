//
//  TaskMediaAddCell.swift
//  WisdriIS
//
//  Created by Allen on 4/9/16.
//  Copyright © 2016 WisdriIS. All rights reserved.
//

import UIKit

class TaskMediaAddCell: UICollectionViewCell {

    @IBOutlet weak var mediaAddImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        mediaAddImage.tintColor = UIColor.wisTintColor()
        contentView.backgroundColor = UIColor.wisBackgroundColor()
    }
}
