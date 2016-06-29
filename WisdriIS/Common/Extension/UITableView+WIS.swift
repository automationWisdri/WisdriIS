//
//  UITableView+Extension.swift
//  WisdriIS
//
//  Created by Allen on 2/20/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

extension NSObject {
    /**
     当前的类名字符串
     
     - returns: 当前类名的字符串
     */
    public class func Identifier() -> String {
        return "\(self)";
    }
}

extension String {
    public var Length:Int {
        get{
            return self.characters.count;
        }
    }
}


/**
 向 tableView 注册 UITableViewCell
 
 - parameter tableView: tableView
 - parameter cell:      要注册的类名
 */
// func regClass(tableView: UITableView, cell: AnyClass) -> Void {
//     tableView.registerClass(cell, forCellReuseIdentifier: cell.Identifier())
// }

/**
 从 tableView 缓存中取出对应类型的 Cell
 如果缓存中没有，则重新创建一个
 
 - parameter tableView: tableView
 - parameter cell:      要返回的Cell类型
 - parameter indexPath: 位置
 
 - returns: 传入 Cell 类型的实例对象
 */
func getCell<T: UITableViewCell>(tableView:UITableView ,cell: T.Type ,indexPath:NSIndexPath) -> T {
    return tableView.dequeueReusableCellWithIdentifier("\(cell)", forIndexPath: indexPath) as! T
}

func wisFont(fontSize: CGFloat) -> UIFont {
    return UIFont.systemFontOfSize(fontSize)
//    return UIFont(name: "Helvetica", size: fontSize);
}

