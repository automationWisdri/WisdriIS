//
//  UIImageView+WIS.swift
//  WisdriIS
//
//  Created by Allen on 5/12/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - ActivityIndicator

private var activityIndicatorKey: Void?
private var showActivityIndicatorWhenLoadingKey: Void?

extension UIImageView {

    private var wis_activityIndicator: UIActivityIndicatorView? {
        return objc_getAssociatedObject(self, &activityIndicatorKey) as? UIActivityIndicatorView
    }

    private func wis_setActivityIndicator(activityIndicator: UIActivityIndicatorView?) {
        objc_setAssociatedObject(self, &activityIndicatorKey, activityIndicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var wis_showActivityIndicatorWhenLoading: Bool {
        get {
            guard let result = objc_getAssociatedObject(self, &showActivityIndicatorWhenLoadingKey) as? NSNumber else {
                return false
            }

            return result.boolValue
        }

        set {
            if wis_showActivityIndicatorWhenLoading == newValue {
                return

            } else {
                if newValue {
                    let indicatorStyle = UIActivityIndicatorViewStyle.Gray
                    let indicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
                    indicator.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))

                    indicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin, .FlexibleTopMargin]
                    indicator.hidden = true
                    indicator.hidesWhenStopped = true

                    self.addSubview(indicator)

                    wis_setActivityIndicator(indicator)

                } else {
                    wis_activityIndicator?.removeFromSuperview()
                    wis_setActivityIndicator(nil)
                }

                objc_setAssociatedObject(self, &showActivityIndicatorWhenLoadingKey, NSNumber(bool: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

// MARK: - AttachmentURL

private var attachmentURLKey: Void?

extension UIImageView {

    private var wis_attachmentURL: NSURL? {
        return objc_getAssociatedObject(self, &attachmentURLKey) as? NSURL
    }

    private func wis_setAttachmentURL(URL: NSURL) {
        objc_setAssociatedObject(self, &attachmentURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func wis_setImageOfAttachment(file: WISFileInfo) {


        let showActivityIndicatorWhenLoading = wis_showActivityIndicatorWhenLoading
        var activityIndicator: UIActivityIndicatorView? = nil

        if showActivityIndicatorWhenLoading {
            activityIndicator = wis_activityIndicator
            activityIndicator?.hidden = false
            activityIndicator?.startAnimating()
        }

        var imagesInfo = [String : WISFileInfo]()
        imagesInfo[file.fileName] = file
        
        WISDataManager.sharedInstance().obtainImageOfMaintenanceTaskWithTaskID(currentTask?.taskID, imagesInfo: imagesInfo, downloadProgressIndicator: { progress in
//            print("imagesInfo 获取成功，正在下载图片")
            // NSLog("Download progress is %f", progress.fractionCompleted)
            }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                
                if completedWithNoError {
                    // 图片获取成功
                    let imagesDictionary = data as! Dictionary<String, UIImage>
                    
                    UIView.transitionWithView(self, duration: imageFadeTransitionDuration, options: .TransitionCrossDissolve, animations: { () -> Void in
                        self.image = imagesDictionary[file.fileName]
                    }, completion: nil)

                    activityIndicator?.stopAnimating()
                }
        })

    }
}

// MARK: - Location

private var locationxKey: Void?

extension UIImageView {

    private var wis_location: CLLocation? {
        return objc_getAssociatedObject(self, &locationxKey) as? CLLocation
    }

    private func wis_setLocation(location: CLLocation) {
        objc_setAssociatedObject(self, &locationxKey, location, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func wis_setImageOfLocation(location: CLLocation, withSize size: CGSize) {

        let showActivityIndicatorWhenLoading = wis_showActivityIndicatorWhenLoading
        var activityIndicator: UIActivityIndicatorView? = nil

        if showActivityIndicatorWhenLoading {
            activityIndicator = wis_activityIndicator
            activityIndicator?.hidden = false
            activityIndicator?.startAnimating()
        }

        wis_setLocation(location)

//        ImageCache.sharedInstance.mapImageOfLocationCoordinate(location.coordinate, withSize: size, completion: { [weak self] image in
//
//            guard let strongSelf = self, _location = strongSelf.wis_location where _location == location else {
//                return
//            }
//
//            UIView.transitionWithView(strongSelf, duration: imageFadeTransitionDuration, options: .TransitionCrossDissolve, animations: { () -> Void in
//                strongSelf.image = image
//            }, completion: nil)
//
//            activityIndicator?.stopAnimating()
//        })
    }
}

