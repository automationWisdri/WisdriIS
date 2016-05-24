//
//  MediaViewCell.swift
//  WisdriIS
//
//  Created by Allen on 5/10/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class MediaViewCell: UICollectionViewCell {

    @IBOutlet weak var mediaView: MediaView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        mediaView.backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mediaView.imageView.image = nil
    }
}

