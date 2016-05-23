//
//  ProfileInfoViewController.swift
//  WisdriIS
//
//  Created by Allen on 5/5/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import SVProgressHUD

class ProfileInfoViewController: UIViewController {

    private let profileInfoCellIdentifier = "ProfileInfoCell"
    
    @IBOutlet weak var profileInfoTableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var introTextView: UITextView!
    
    var segueIdentifier: String?
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(ProfileInfoViewController.post(_:)))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "修改信息"
        
        view.backgroundColor = UIColor.wisBackgroundColor()
        navigationItem.rightBarButtonItem = postButton
        
        profileInfoTableView.tableHeaderView = introView
        profileInfoTableView.registerNib(UINib(nibName: profileInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: profileInfoCellIdentifier)
        
        switch segueIdentifier! {
            
        case "editUserName":
            
            let nameCell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! ProfileInfoCell

            if let fullName = WISDataManager.sharedInstance().currentUser.fullName {
                nameCell.infoTextField.text = fullName
            }
            
        case "editPhone":
        
            let telCell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! ProfileInfoCell
            let mobileCell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! ProfileInfoCell
            
            if let telNumber = WISDataManager.sharedInstance().currentUser.telephoneNumber {
                telCell.infoTextField.text = telNumber
            }
            if let mobileNumber = WISDataManager.sharedInstance().currentUser.cellPhoneNumber {
                mobileCell.infoTextField.text = mobileNumber
            }
        
        default:
            break
        }
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        
        let wisUserForUpdate = WISDataManager.sharedInstance().currentUser
        
        switch segueIdentifier! {
        
        case "editPhone":
                
            let telCell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! ProfileInfoCell
            let mobileCell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! ProfileInfoCell
            
            var telNumber: String?
            var mobileNumber: String?
            
            if telCell.infoTextField.text?.Length > 0 {
                telNumber = telCell.infoTextField.text!
                // 格式判断待完善
                wisUserForUpdate.telephoneNumber = telNumber
            } else {
                telCell.infoTextField.becomeFirstResponder()
                return
            }
            
            if mobileCell.infoTextField.text?.Length > 0 {
                mobileNumber = mobileCell.infoTextField.text!
                // 格式判断待完善
                wisUserForUpdate.cellPhoneNumber = mobileNumber
            } else {
                mobileCell.infoTextField.becomeFirstResponder()
                return
            }
            
        case "editUserName":
            
            let nameCell = profileInfoTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! ProfileInfoCell
            
            var fullName: String?
            
            if nameCell.infoTextField.text?.Length > 0 {
                fullName = nameCell.infoTextField.text!
                // 格式判断待完善
                wisUserForUpdate.fullName = fullName
            } else {
                nameCell.infoTextField.becomeFirstResponder()
                return
            }
            
        default:
            return
        }
        
        SVProgressHUD.showWithStatus("正在提交")
        WISDataManager.sharedInstance().submitUserDetailInfoWithNewInfo(wisUserForUpdate!) { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                SVProgressHUD.showSuccessWithStatus("修改成功")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                WISConfig.errorCode(error)
            }
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    private enum PhoneRow: Int {
        case Tel = 0
        case Mobile
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segueIdentifier! {
        case "editUserName": return 1;
        case "editPhone": return 2;
        default: return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch segueIdentifier! {
            
        case "editUserName":
        
            let cell = tableView.dequeueReusableCellWithIdentifier(profileInfoCellIdentifier) as! ProfileInfoCell
            cell.annotationLabel.text = "用户姓名"
            cell.infoTextField.placeholder = "请填入用户姓名"
            cell.infoTextField.keyboardType = .Default
            return cell
        
        case "editPhone":
        
            switch indexPath.row {
                
            case PhoneRow.Tel.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(profileInfoCellIdentifier) as! ProfileInfoCell
                cell.annotationLabel.text = "固定电话"
                cell.infoTextField.placeholder = "请填入固定电话号码"
                cell.infoTextField.keyboardType = .PhonePad
                return cell
                
            case PhoneRow.Mobile.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(profileInfoCellIdentifier) as! ProfileInfoCell
                cell.annotationLabel.text = "移动电话"
                cell.infoTextField.placeholder = "请填入移动电话号码"
                cell.infoTextField.keyboardType = .PhonePad
                return cell
                
            default:
                return UITableViewCell()
            
            }
        
        default:
            return UITableViewCell()
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60
    }
    
}