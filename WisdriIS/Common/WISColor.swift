//
//  WISColor.swift
//  WisdriIS
//
//  Created by Allen on 3/11/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit


func colorWith255RGB(r:CGFloat , g:CGFloat, b:CGFloat) ->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 255)
}
func colorWith255RGBA(r:CGFloat , g:CGFloat, b:CGFloat,a:CGFloat) ->UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a/255)
}

func createImageWithColor(color:UIColor) -> UIImage{
    return createImageWithColor(color, size: CGSizeMake(1, 1))
}
func createImageWithColor(color:UIColor,size:CGSize) -> UIImage {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContext(rect.size);
    let context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    let theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


//使用协议 方便以后切换颜色配置文件、或者做主题配色之类乱七八糟产品经理最爱的功能

protocol WISColorProtocol{
    var wis_backgroundColor: UIColor { get }
    var wis_navigationBarTintColor: UIColor { get }
    var wis_TopicListTitleColor : UIColor { get }
    var wis_TopicListUserNameColor : UIColor { get }
    var wis_TopicListDateColor : UIColor { get }
    
    var wis_LinkColor : UIColor { get }
    
    var wis_TextViewBackgroundColor: UIColor { get }
    
    var wis_CellWhiteBackgroundColor : UIColor { get }
    
    var wis_NodeBackgroundColor : UIColor { get }
    
    var wis_SeparatorColor : UIColor { get }
    
    var wis_LeftNodeBackgroundColor : UIColor { get }
    var wis_LeftNodeTintColor: UIColor { get }
    
    /// 小红点背景颜色
    var wis_NoticePointColor : UIColor { get }
    
    var wis_ButtonBackgroundColor : UIColor { get }
}

class WISDefaultColor: NSObject,WISColorProtocol {
    static let sharedInstance = WISDefaultColor()
    private override init(){
        super.init()
    }
    
    var wis_backgroundColor : UIColor{
        get{
            return colorWith255RGB(242, g: 243, b: 245);
        }
    }
    var wis_navigationBarTintColor : UIColor{
        get{
            return colorWith255RGB(102, g: 102, b: 102);
        }
    }
    
    
    var wis_TopicListTitleColor : UIColor{
        get{
            return colorWith255RGB(15, g: 15, b: 15);
        }
    }
    
    var wis_TopicListUserNameColor : UIColor{
        get{
            return colorWith255RGB(53, g: 53, b: 53);
        }
    }
    
    var wis_TopicListDateColor : UIColor{
        get{
            return colorWith255RGB(173, g: 173, b: 173);
        }
    }
    
    var wis_LinkColor : UIColor {
        get {
            return colorWith255RGB(119, g: 128, b: 135)
        }
    }
    
    var wis_TextViewBackgroundColor :UIColor {
        get {
            return colorWith255RGB(255, g: 255, b: 255)
        }
    }
    
    var wis_CellWhiteBackgroundColor :UIColor {
        get {
            return colorWith255RGB(255, g: 255, b: 255)
        }
    }
    
    var wis_NodeBackgroundColor : UIColor {
        get {
            return colorWith255RGB(242, g: 242, b: 242)
        }
    }
    var wis_SeparatorColor : UIColor {
        get {
            return colorWith255RGB(190, g: 190, b: 190)
        }
    }
    
    var wis_LeftNodeBackgroundColor : UIColor {
        get {
            return colorWith255RGBA(255, g: 255, b: 255, a: 76)
        }
    }
    var wis_LeftNodeTintColor : UIColor {
        get {
            return colorWith255RGBA(0, g: 0, b: 0, a: 140)
        }
    }
    
    var wis_NoticePointColor : UIColor {
        get {
            return colorWith255RGB(207, g: 70, b: 71)
        }
    }
    var wis_ButtonBackgroundColor : UIColor {
        get {
            return colorWith255RGB(85, g: 172, b: 238)
        }
    }
}


/// Dark Colors
class WISDarkColor: NSObject,WISColorProtocol {
    static let sharedInstance = WISDarkColor()
    private override init(){
        super.init()
    }
    
    var wis_backgroundColor : UIColor{
        get{
            return colorWith255RGB(32, g: 31, b: 35);
        }
    }
    var wis_navigationBarTintColor : UIColor{
        get{
            return colorWith255RGB(165, g: 165, b: 165);
        }
    }
    
    
    var wis_TopicListTitleColor : UIColor{
        get{
            return colorWith255RGB(145, g: 145, b: 145);
        }
    }
    
    var wis_TopicListUserNameColor : UIColor{
        get{
            return colorWith255RGB(125, g: 125, b: 125);
        }
    }
    
    var wis_TopicListDateColor : UIColor{
        get{
            return colorWith255RGB(100, g: 100, b: 100);
        }
    }
    
    var wis_LinkColor : UIColor {
        get {
            return colorWith255RGB(119, g: 128, b: 135)
        }
    }
    
    var wis_TextViewBackgroundColor :UIColor {
        get {
            return colorWith255RGB(35, g: 34, b: 38)
        }
    }
    
    var wis_CellWhiteBackgroundColor :UIColor {
        get {
            return colorWith255RGB(35, g: 34, b: 38)
        }
    }
    
    var wis_NodeBackgroundColor : UIColor {
        get {
            return colorWith255RGB(40, g: 40, b: 40)
        }
    }
    var wis_SeparatorColor : UIColor {
        get {
            return colorWith255RGB(46, g: 45, b: 49)
        }
    }
    
    var wis_LeftNodeBackgroundColor : UIColor {
        get {
            return colorWith255RGBA(255, g: 255, b: 255, a: 76)
        }
    }
    var wis_LeftNodeTintColor : UIColor {
        get {
            return colorWith255RGBA(0, g: 0, b: 0, a: 140)
        }
    }
    
    var wis_NoticePointColor : UIColor {
        get {
            return colorWith255RGB(207, g: 70, b: 71)
        }
    }
    var wis_ButtonBackgroundColor : UIColor {
        get {
            return colorWith255RGB(207, g: 70, b: 71)
        }
    }
}


class WISColor :NSObject  {
    private static let STYLE_KEY = "styleKey"
    
    static let WISColorStyleDefault = "Default"
    static let WISColorStyleDark = "Dark"
    
    private static var _colors:WISColorProtocol?
    static var colors :WISColorProtocol {
        get{
            
            if let c = WISColor._colors {
                return c
            }
            else{
                if WISColor.sharedInstance.style == WISColor.WISColorStyleDefault{
                    return WISDefaultColor.sharedInstance
                }
                else{
                    return WISDarkColor.sharedInstance
                }
            }
            
        }
        set{
            WISColor._colors = newValue
        }
    }
    
    dynamic var style:String
    static let sharedInstance = WISColor()
    private override init(){
        if let style = WISSettings.sharedInstance[WISColor.STYLE_KEY] {
            self.style = style
        }
        else{
            self.style = WISColor.WISColorStyleDefault
        }
        super.init()
    }
    func setStyleAndSave(style:String){
        if self.style == style {
            return
        }
        
        if style == WISColor.WISColorStyleDefault {
            WISColor.colors = WISDefaultColor.sharedInstance
        }
        else{
            WISColor.colors = WISDarkColor.sharedInstance
        }
        
        self.style = style
        WISSettings.sharedInstance[WISColor.STYLE_KEY] = style
        WISSettings.sharedInstance.save()
    }
    
}
