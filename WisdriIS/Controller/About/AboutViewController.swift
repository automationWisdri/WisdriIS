//
//  AboutViewController.swift
//  WisdriIS
//
//  Created by Allen on 5/8/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Ruler
import SVProgressHUD
import Foundation

class AboutViewController: BaseViewController {

    @IBOutlet private weak var appLogoImageView: UIImageView!
    @IBOutlet private weak var appLogoImageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var appVersionLabel: UILabel!
    
    @IBOutlet private weak var aboutTableView: UITableView!
    @IBOutlet private weak var aboutTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutTableViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var copyrightLabel: UILabel!

    private let profileLessInfoCellID = "ProfileLessInfoCell"

    private let rowHeight: CGFloat = Ruler.iPhoneVertical(50, 60, 60, 60).value

    override func viewDidLoad() {
        
        super.viewDidLoad()

        title = NSLocalizedString("About", comment: "")

        appLogoImageViewTopConstraint.constant = Ruler.iPhoneVertical(50, 70, 90, 110).value
        appNameLabelTopConstraint.constant = Ruler.iPhoneVertical(20, 30, 30, 30).value
        aboutTableViewTopConstraint.constant = Ruler.iPhoneVertical(140, 190, 270, 325).value

        appNameLabel.textColor = UIColor.wisLogoColor()

        aboutTableView.registerNib(UINib(nibName: profileLessInfoCellID, bundle: nil), forCellReuseIdentifier: profileLessInfoCellID)

        aboutTableViewHeightConstraint.constant = rowHeight + 1
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {

    private enum Row: Int {
        case Cache = 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.row {
            
        case 0:
            return UITableViewCell()
            
        default:
        
            let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellID) as! ProfileLessInfoCell
            
            cell.annotationLabel.text = "清除缓存"
            
            let cacheSize = WISDataManager.sharedInstance().cacheSizeOnDeviceStorage()
            cell.infoLabel.text = String(format: "%.1f", cacheSize) + " MB"
            
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 1
        default:
            return rowHeight
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        switch indexPath.row {
            
        case Row.Cache.rawValue:
            
            WISAlert.confirmOrCancel(title: "注意", message: "是否清除本地缓存？", confirmTitle: "清除", cancelTitle: "取消", inViewController: self, withConfirmAction: {
                    SVProgressHUD.showWithStatus("正在清除")
                    delay(1.5, work: {
                        WISDataManager.sharedInstance().clearCacheOfImages()
                        SVProgressHUD.dismiss()
                        dispatch_async(dispatch_get_main_queue()) {
                            self.aboutTableView.reloadData()
                        }
                    })
                }, cancelAction: {})
            
        default:
            break
        }
    }
}

