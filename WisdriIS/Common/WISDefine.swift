//
//  WISDefine.swift
//  WisdriIS
//
//  Created by Allen on 1/11/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD





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

