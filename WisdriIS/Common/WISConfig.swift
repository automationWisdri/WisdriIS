//
//  WISConfig.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import Ruler
import CoreLocation
import SVProgressHUD

let avatarFadeTransitionDuration: NSTimeInterval = 0.0
let bigAvatarFadeTransitionDuration: NSTimeInterval = 0.15
let imageFadeTransitionDuration: NSTimeInterval = 0.2

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width

let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height

let EMPTY_STRING = ""

let SEPARATOR_HEIGHT = 1.0 / UIScreen.mainScreen().scale

func NSLocalizedString(key: String) -> String {
    return NSLocalizedString(key, comment: EMPTY_STRING)
}

class WISConfig {
    
    static let minMessageTextLabelWidth: CGFloat = 20.0
    
    static let minMessageSampleViewWidth: CGFloat = 25.0
    
    static let maxTaskTextLength: Int = 300
    
    class func clientType() -> Int {
        // TODO: clientType
        
        #if DEBUG
            return 2
        #else
            return 0
        #endif
    }

    static let appURLString = "itms-apps://itunes.apple.com/app/id" + "......"

    static let forcedHideActivityIndicatorTimeInterval: NSTimeInterval = 30

    static let dismissKeyboardDelayTimeInterval : NSTimeInterval = 0.45

    class func getScreenRect() -> CGRect {
        return UIScreen.mainScreen().bounds
    }

    class func avatarMaxSize() -> CGSize {
        return CGSize(width: 414, height: 414)
    }

    class func userCellAvatarSize() -> CGFloat {
        return 40.0
    }

    class func avatarCompressionQuality() -> CGFloat {
        return 0.7
    }

    class func profileAvatarSize() -> CGFloat {
        return 100
    }
    
    struct TaskListCell {
        static let separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
    }

    struct ContactsCell {
        static let separatorInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
    }
   
    struct TaskDescriptionCell {
        static let textAttributes:[String: NSObject] = [
            NSFontAttributeName: UIFont.textViewFont(),
        ]
    }
    
    struct Profile {
        static let leftEdgeInset: CGFloat = Ruler.iPhoneHorizontal(20, 38, 40).value
        static let rightEdgeInset: CGFloat = leftEdgeInset
    }
    
    struct MediaCollection {
        static let leftEdgeInset: CGFloat = 20
    }

    struct MetaData {
        static let audioDuration = "audio_duration"
        static let audioSamples = "audio_samples"

        static let imageWidth = "image_width"
        static let imageHeight = "image_height"

        static let videoWidth = "video_width"
        static let videoHeight = "video_height"

        static let thumbnailString = "thumbnail_string"
        static let blurredThumbnailString = "blurred_thumbnail_string"

        static let thumbnailMaxSize: CGFloat = 100
    }
    
    struct TaskMedia {
        static let backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
    }

    struct Media {
        static let imageWidth: CGFloat = 2048
        static let imageHeight: CGFloat = 2048

        static let miniImageWidth: CGFloat = 200
        static let miniImageHeight: CGFloat = 200
    }

    struct Feedback {
        static let bottomMargin: CGFloat = Ruler.iPhoneVertical(10, 20, 40, 40).value
    }

    struct Location {
        static let distanceThreshold: CLLocationDistance = 500
    }

    static let DATE: NSDateFormatter = {
        var date = NSDateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm"
        return date
    }()
    
    
    
    class func dispatch_sync_safely_main_queue(block: ()->()) {
        if NSThread.isMainThread() {
            block()
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                block()
            }
        }
    }
    
    class func taskStateImage(state: String) -> UIImage {
        
        guard !state.isEmpty else {
            return UIImage(named: "icon_current_location")!
        }
        
        switch state {
        case "提交维保方案.":
            return UIImage(named: "icon_subscribe_notify")!
        case "等待接单.":
            return UIImage(named: "icon_current_location")!
        default:
            return UIImage(named: "icon_minicard")!
            
        }
    }
    
    class func errorCode(error: NSError, customInformation: String = "") {
        
        let customString = (customInformation == "" ? "" : customInformation + "\n\n " + "原因: ")
        
        SVProgressHUD.setDefaultMaskType(.None)
        guard let errorCode = WISErrorCode(rawValue: error.code) else {
            SVProgressHUD.showErrorWithStatus(customString + "内部错误")
            return
        }
        
        switch errorCode {
        case .ErrorCodeInvalidOperation:
            SVProgressHUD.showErrorWithStatus(customString + "操作非法")
            return
        case .ErrorCodeIncorrectResponsedDataFormat:
            SVProgressHUD.showErrorWithStatus(customString + "数据解析失败")
            return
        case .ErrorCodeNetworkTransmission:
            SVProgressHUD.showErrorWithStatus(customString + "网络传输错误")
            return
        case .ErrorCodeResponsedNULLData:
            SVProgressHUD.showErrorWithStatus(customString + "服务器返回数据错误")
            return
        case .ErrorCodeWrongFuncParameters:
            SVProgressHUD.showErrorWithStatus(customString + "函数参数错误")
            return
        case .ErrorCodeNoCurrentUserInfo:
            SVProgressHUD.showErrorWithStatus("请重新登录")
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                appDelegate.window?.rootViewController = LoginViewController()
            }
        default:
            SVProgressHUD.showErrorWithStatus(customString + "未知错误")
            return
        }
    }
    
    class func configureStateText(state: String) -> String {
        
        let seperator = "."
        let rangeOfLastCharacter = state.endIndex.advancedBy(-1) ..< state.endIndex // Range(start: state.endIndex.advancedBy(-1), end: state.endIndex)
        
        guard state.contains(seperator) else {
            return state
        }
        
        let rangeOfSeperator = state.rangeOfString(seperator)
        
        if state.substringWithRange(rangeOfLastCharacter) == seperator {
            return String(state.characters.prefixUpTo(rangeOfSeperator!.startIndex))
        } else {
            return String(state.characters.suffixFrom(rangeOfSeperator!.endIndex))
        }
        
    }
}

