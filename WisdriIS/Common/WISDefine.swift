//
//  WISDefine.swift
//  WisdriIS
//
//  Created by Allen on 1/11/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

let EMPTY_STRING = ""

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height

let LightBundel = NSBundle(path: NSBundle.mainBundle().pathForResource("Light", ofType: "bundle")!)!
let DarkBundel = NSBundle(path: NSBundle.mainBundle().pathForResource("Dark", ofType: "bundle")!)!
let CurrentBundel = LightBundel

// 用户代理，使用这个切换是获取 m 站还是 www 站数据
let USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"
let MOBILE_CLIENT_HEADERS = ["user-agent": USER_AGENT]

//CSS配色
let LIGHT_CSS = try! String(contentsOfFile: LightBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)
let DARK_CSS = try! String(contentsOfFile: DarkBundel.pathForResource("style", ofType: "css")!, encoding: NSUTF8StringEncoding)

// 站点地址
let WISURL = "http://"

let SEPARATOR_HEIGHT = 1.0 / UIScreen.mainScreen().scale

let DATE: NSDateFormatter = {
    var date = NSDateFormatter()
    date.dateFormat = "yyyy-MM-dd HH:mm"
    return date
}()

extension UIImage {
    convenience init? (imageNamed: String){
        self.init(named: imageNamed, inBundle: CurrentBundel, compatibleWithTraitCollection: nil)
    }
    class func imageUsedTemplateMode(named:String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return nil
        }
        return image!.imageWithRenderingMode(.AlwaysTemplate)
    }
}

func NSLocalizedString(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}


func dispatch_sync_safely_main_queue(block: ()->()) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_sync(dispatch_get_main_queue()) {
            block()
        }
    }
}

func taskStateImage(state: String) -> UIImage {
    
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

func errorCode(error: NSError) {
    
    guard let errorCode = WISErrorCode(rawValue: error.code) else {
        SVProgressHUD.showErrorWithStatus("内部错误")
        return
    }
    
    switch errorCode {
    case .ErrorCodeInvalidOperation:
        SVProgressHUD.showErrorWithStatus("操作非法")
        return
    case .ErrorCodeIncorrectResponsedDataFormat:
        SVProgressHUD.showErrorWithStatus("数据解析失败")
        return
    case .ErrorCodeNetworkTransmission:
        SVProgressHUD.showErrorWithStatus("网络传输错误")
        return
    case .ErrorCodeResponsedNULLData:
        SVProgressHUD.showErrorWithStatus("服务器返回数据错误")
        return
    case .ErrorCodeWrongFuncParameters:
        SVProgressHUD.showErrorWithStatus("函数参数错误")
        return
    case .ErrorCodeNoCurrentUserInfo:
        SVProgressHUD.showErrorWithStatus("请重新登录")
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.window?.rootViewController = LoginViewController()
        }
    default:
        SVProgressHUD.showErrorWithStatus("未知错误")
        return
    }

}

func configureStateText(state: String) -> String {
    
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