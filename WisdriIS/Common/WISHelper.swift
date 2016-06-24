//
//  WISHelper.swift
//  WisdriIS
//
//  Created by Allen on 5/5/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation
//import Navi

enum ValidateType: Int {
    case Phone = 0
    case Name
}

typealias CancelableTask = (cancel: Bool) -> Void

extension String {
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
}

func delay(time: NSTimeInterval, work: dispatch_block_t) -> CancelableTask? {

    var finalTask: CancelableTask?

    let cancelableTask: CancelableTask = { cancel in
        if cancel {
            finalTask = nil // key

        } else {
            dispatch_async(dispatch_get_main_queue(), work)
        }
    }

    finalTask = cancelableTask

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        if let task = finalTask {
            task(cancel: false)
        }
    }

    return finalTask
}

func cancel(cancelableTask: CancelableTask?) {
    cancelableTask?(cancel: true)
}

//func unregisterThirdPartyPush() {
//    dispatch_async(dispatch_get_main_queue()) {
//        //JPUSHService.setAlias(nil, callbackSelector: nil, object: nil)
//        APService.setAlias(nil, callbackSelector: nil, object: nil)
//        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
//    }
//}

func isOperatingSystemAtLeastMajorVersion(majorVersion: Int) -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: majorVersion, minorVersion: 0, patchVersion: 0))
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(path)
    }
}


func cleanDiskCacheFolder() {
    
    let folderPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
    let fileMgr = NSFileManager.defaultManager()
    
    guard let fileArray = try? fileMgr.contentsOfDirectoryAtPath(folderPath) else {
        return
    }
    
    for filename in fileArray  {
        do {
            try fileMgr.removeItemAtPath(folderPath.stringByAppendingPathComponent(filename))
        } catch {
            print(" clean error ")
        }
        
    }
}

/// 字符串格式判断
func validateFormat(validateString string: String, type: ValidateType) -> Bool {
    
    do {
        let phonePattern = "^(\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1\\d{10}|\\d{8}|\\d{7})$"
        let chineseCharacterPattern = "^[\\u4e00-\\u9fa5]{2,6}$"
//        let mobilePattern = "^(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$"
        var regex = NSRegularExpression()
        
        switch type {
            case .Name:
                regex = try NSRegularExpression(pattern: chineseCharacterPattern, options: .CaseInsensitive)
            case .Phone:
                regex = try NSRegularExpression(pattern: phonePattern, options: .CaseInsensitive)
        }
        
        let matches = regex.matchesInString(string, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, string.characters.count))
        
        return matches.count > 0
        
    }
    catch {
        print("Format Error")
        return false
    }
    
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UINavigationBar {

    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView?.hidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView?.hidden = false
    }
    
    func changeBottomHairImage() {
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if let view = view as? UIImageView where view.bounds.height <= 1.0 {
            return view
        }

        for subview in view.subviews {
            if let imageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }

        return nil
    }
}

