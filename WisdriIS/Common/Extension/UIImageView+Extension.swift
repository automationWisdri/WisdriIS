//
//  UIImageView+Extension.swift
//  WisdriIS
//
//  Created by Allen on 2/20/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Kingfisher

private var lastURLKey: Void?

extension UIImageView {
    
    public var wis_webURL: NSURL? {
        return objc_getAssociatedObject(self, &lastURLKey) as? NSURL
    }
    
    private func wis_setWebURL(URL: NSURL) {
        objc_setAssociatedObject(self, &lastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func wis_setImageWithUrl (URL: NSURL ,placeholderImage: UIImage?
        ,imageModificationClosure:((image:UIImage) -> UIImage)?){
            
            self.image = placeholderImage
        
            let resource = Resource(downloadURL: URL)
            wis_setWebURL(resource.downloadURL)
            
            let options = KingfisherManager.DefaultOptions
            
            KingfisherManager.sharedManager.cache.retrieveImageForKey(resource.cacheKey, options: options) { (image, cacheType) -> () in
                if image != nil {
                    dispatch_sync_safely_main_queue({ () -> () in
                        self.image = image
                    })
                }
                else {
                    KingfisherManager.sharedManager.downloader.downloadImageWithURL(resource.downloadURL, options: options, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) -> () in
                        if let error = error where error.code == KingfisherError.NotModified.rawValue {
                            KingfisherManager.sharedManager.cache.retrieveImageForKey(resource.cacheKey, options: KingfisherManager.DefaultOptions, completionHandler: { (cacheImage, cacheType) -> () in
                                self.wis_setImage(cacheImage!, imageURL: imageURL!)
                            })
                            return
                        }
                        
                        if var image = image, let originalData = originalData {
                            //处理图片
                            if let img = imageModificationClosure?(image: image) {
                                image = img
                            }
                            
                            //保存图片缓存
                            KingfisherManager.sharedManager.cache.storeImage(image, originalData: originalData, forKey: resource.cacheKey, toDisk: !KingfisherManager.DefaultOptions.cacheMemoryOnly, completionHandler: nil)
                            self.wis_setImage(image, imageURL: imageURL!)
                        }
                    })
                }
            }
    }
    
    private func wis_setImage(image: UIImage, imageURL: NSURL) {
        
        dispatch_sync_safely_main_queue { () -> () in
            guard imageURL == self.wis_webURL else {
                return
            }
            self.image = image
        }
        
    }
    
}

func wis_defaultImageModification() -> ((image:UIImage) -> UIImage) {
    return { (var image) -> UIImage in
        image = image.roundedCornerImageWithCornerRadius(3)
        return image
    }
}
