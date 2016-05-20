//
//  TaskMediaCell.swift
//  WisdriIS
//
//  Created by Allen on 4/9/16.
//  Copyright © 2015 Wisdri. All rights reserved.
//

import UIKit

class TaskMediaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.backgroundColor = WISConfig.TaskMedia.backgroundColor
        imageView.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        imageView.layer.borderColor = UIColor.wisBorderColor().CGColor
        
        contentView.backgroundColor = UIColor.clearColor()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func configureWithImage(image: UIImage) {

        imageView.image = image
//        print(imageView.image?.description)
        deleteImageView.hidden = false
//        deleteImageView.hidden = true
    }
    
    func configureWithFileInfo(file: WISFileInfo) {

        imageView.yep_showActivityIndicatorWhenLoading = true
        imageView.yep_setImageOfAttachment(file)
        deleteImageView.hidden = true
        
    }
    
    
}