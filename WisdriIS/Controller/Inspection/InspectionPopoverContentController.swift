//
//  InspectionPopoverContentController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/16/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SnapKit

class InspectionPopoverMenuController: UIViewController {
   
    let menuItemCodeScanID = "menuItemCodeScan"
    let menuItemUploadingQueueID = "menuItemUploadingQueue"
    let menuItemInspectionResultRecordID = "menuItemInspectionResultRecord"
    
    let menuTableViewPreferedSize = CGSizeMake(240.0, 100.0)
    let menuTableViewCellPreferedHeight = CGFloat.init(50.0)
    
    var menuTableView : UITableView?
    
    let menuTableViewForeGroundColor = UIColor.darkGrayColor()
    
    var PopoverSuperController:UIViewController?
    var PopoverMenuItemTapedCompletion:((meunItem:InspectionPopoverMenuItem)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Size of menuTableView should be adjusted by code
        menuTableView = UITableView.init(frame: CGRectMake(0.0, 0.0, menuTableViewPreferedSize.width, menuTableViewPreferedSize.height), style: .Plain)
        // menuTableView = UITableView.init()
        // menuTableView!.bounds = CGRectMake(0.0, 0.0, 150.0, 120)
        menuTableView!.scrollEnabled = false
        menuTableView!.allowsMultipleSelection = false
        menuTableView!.indicatorStyle = .Default
        // menuTableView!.separatorStyle = .SingleLine
        // menuTableView!.separatorInset = WISConfig.ContactsCell.separatorInset
        menuTableView!.separatorInset.left = WISConfig.Profile.leftEdgeInset
        // menuTableView!.separatorInset.right = WISConfig.Profile.rightEdgeInset
        menuTableView!.separatorColor = UIColor.wisCellSeparatorColor()
        
        menuTableView!.delegate = self
        menuTableView!.dataSource = self
        
        //self.view.addSubview(menuTableView!)
        self.view = menuTableView
        
        // let sizeOfTableView = menuTableView!.bounds.size
        // self.view.sizeThatFits(sizeOfTableView)
        self.view.sizeToFit()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissInspectionPopoverMenu() -> Void {
        self.dismissViewControllerAnimated(true) {
            print("关闭点检弹出菜单")
        }
    }
}


/// MARK: DataSource and Delegate
extension InspectionPopoverMenuController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.menuTableViewCellPreferedHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: menuItemCodeScanID)
            cell.selectionStyle = .Blue
            cell.contentView.backgroundColor = menuTableViewForeGroundColor
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.font = UIFont.navigationBarTitleFont()
            cell.textLabel!.text = NSLocalizedString("Scan QRCode")
//            cell.imageView?.image = UIImage(named: "CodeScan.bundle/device_scan")
            cell.imageView?.image = UIImage(named: "icon_qr_scanner")
            cell.accessoryType = .None
            cell.selectedBackgroundView?.backgroundColor = UIColor.blueColor()
            
//            cell.imageView!.snp_makeConstraints{ (make) -> Void in
//                make.centerY.equalTo(cell.contentView)
//                make.left.equalTo(cell.contentView).offset(15)
//                make.width.height.equalTo(25)
//            }
//            
//            cell.textLabel!.snp_makeConstraints{ (make) -> Void in
//                make.centerY.equalTo(cell.contentView)
//                make.left.equalTo(cell.contentView).offset(55)
//            }
            
            return cell
            
        case 1:
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: menuItemUploadingQueueID)
            cell.selectionStyle = .Blue
            cell.contentView.backgroundColor = menuTableViewForeGroundColor
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.font = UIFont.navigationBarTitleFont()
            cell.textLabel!.text = NSLocalizedString("Uploading Queue")
//            cell.imageView?.image = UIImage(named: "ic_menu_36pt")
            cell.imageView?.image = UIImage(named: "icon_list")
            cell.accessoryType = .None
            cell.selectedBackgroundView?.backgroundColor = UIColor.blueColor()
            
//            cell.imageView!.snp_makeConstraints{ (make) -> Void in
//                make.centerY.equalTo(cell.contentView)
//                make.left.equalTo(cell.contentView).offset(12)
//                make.width.height.equalTo(32)
//            }
//            
//            cell.textLabel!.snp_makeConstraints{ (make) -> Void in
//                make.centerY.equalTo(cell.contentView)
//                make.left.equalTo(cell.contentView).offset(55)
//            }
            
            return cell
            
        case 2:
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: menuItemInspectionResultRecordID)
            cell.selectionStyle = .Blue
            cell.contentView.backgroundColor = menuTableViewForeGroundColor
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.font = UIFont.navigationBarTitleFont()
            cell.textLabel!.text = NSLocalizedString("Historical Inspections")
            cell.imageView?.image = UIImage()
            cell.accessoryType = .None
            cell.selectedBackgroundView?.backgroundColor = UIColor.blueColor()
            return cell
        
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0, 1, 2:
            tableView.cellForRowAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.blackColor()
            self.PopoverMenuItemTapedCompletion!(meunItem: InspectionPopoverMenuItem(rawValue: indexPath.row)!)
            break;
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0, 1, 2:
            tableView.cellForRowAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.blackColor()
            break;
            
        default:
            break
        }
    }
}


enum InspectionPopoverMenuItem: Int {
    ///扫描二维码
    case ScanQRCode = 0
    ///点检结果上传队列
    case UploadingQueue = 1
    ///历史点检结果
    case HistoricalInspection = 2
}


