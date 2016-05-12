//
//  PhotoCell.swift
//  WisdriIS
//
//  Created by Allen on 3/2/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoPickedImageView: UIImageView!

    var imageManager: PHImageManager?

    var imageAsset: PHAsset? {
        willSet {
            guard let imageAsset = newValue else {
                return
            }

            let options = PHImageRequestOptions.wis_sharedOptions

            self.imageManager?.requestImageForAsset(imageAsset, targetSize: CGSize(width: 120, height: 120), contentMode: .AspectFill, options: options) { [weak self] image, info in
                self?.photoImageView.image = image
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

