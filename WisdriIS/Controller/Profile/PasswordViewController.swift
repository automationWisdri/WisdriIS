//
//  PasswordViewController.swift
//  WisdriIS
//
//  Created by Allen on 16/5/2.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import SVProgressHUD

class PasswordViewController: BaseViewController {
    
    private let profilePasswordCellIdentifier = "ProfilePasswordCell"

    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var introTextView: UITextView!
    
    @IBOutlet weak var passwordTableView: TPKeyboardAvoidingTableView!
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(PasswordViewController.post(_:)))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.yepBackgroundColor()
        title = NSLocalizedString("Edit Password", comment: "")
        navigationItem.rightBarButtonItem = postButton
        
        passwordTableView.tableHeaderView = introView
        passwordTableView.registerNib(UINib(nibName: profilePasswordCellIdentifier, bundle: nil), forCellReuseIdentifier: profilePasswordCellIdentifier)
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
        
        let currentPasswordCell = passwordTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as! ProfilePasswordCell
        let newPasswordCell = passwordTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! ProfilePasswordCell
        let repeatNewPasswordCell = passwordTableView.cellForRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0)) as! ProfilePasswordCell
        
        var currentPassword: String?
        var newPassword: String?
        var repeatNewPassword: String?
        
        if currentPasswordCell.infoTextField.text?.Length > 0 {
            currentPassword = currentPasswordCell.infoTextField.text!
        } else {
            currentPasswordCell.infoTextField.becomeFirstResponder()
            return
        }
        
        if newPasswordCell.infoTextField.text?.Length > 0 {
            newPassword = newPasswordCell.infoTextField.text!
        } else {
            newPasswordCell.infoTextField.becomeFirstResponder()
            return
        }
        
        if repeatNewPasswordCell.infoTextField.text?.Length > 0 {
            repeatNewPassword = repeatNewPasswordCell.infoTextField.text!
        } else {
            repeatNewPasswordCell.infoTextField.becomeFirstResponder()
            return
        }

        guard currentPassword == WISDataManager.sharedInstance().networkRequestToken else {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showErrorWithStatus("当前密码输入错误")
            currentPasswordCell.infoTextField.becomeFirstResponder()
            return
        }
        
        guard repeatNewPassword == newPassword else {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showErrorWithStatus("两次输入的密码不相同")
            repeatNewPasswordCell.infoTextField.becomeFirstResponder()
            return
        }

        SVProgressHUD.showWithStatus("正在提交")
        WISDataManager.sharedInstance().changePasswordWithCurrentPassword(currentPassword, newPassword: newPassword, compeletionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                SVProgressHUD.showSuccessWithStatus("修改成功\n请重新登录")
                //                    self.navigationController?.popViewControllerAnimated(true)
                
                // 淡入淡出动画待完善
                UIView.animateWithDuration(0.5, delay: 1.5, options: .CurveEaseOut, animations: { [weak self] in
                    self?.view.alpha = 0
                    }, completion: { _ in
                        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                            appDelegate.window?.rootViewController = LoginViewController()
                        }
                })
                
            } else {
                errorCode(error)
            }
        })
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

extension PasswordViewController: UITableViewDataSource, UITableViewDelegate {
    
    private enum PasswordRow: Int {
        case CurrentPassword = 0
        case NewPassword
        case RepeatPassword
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
                
        case PasswordRow.CurrentPassword.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(profilePasswordCellIdentifier) as! ProfilePasswordCell
                
            cell.annotationLabel.text = NSLocalizedString("Old Password", comment: "")
            cell.infoTextField.placeholder = "请填入当前密码"

            return cell
                
        case PasswordRow.NewPassword.rawValue:
                
            let cell = tableView.dequeueReusableCellWithIdentifier(profilePasswordCellIdentifier) as! ProfilePasswordCell
            
            cell.annotationLabel.text = NSLocalizedString("New Password", comment: "")
            cell.infoTextField.placeholder = "请设置新密码"
            
            return cell
                
        case PasswordRow.RepeatPassword.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(profilePasswordCellIdentifier) as! ProfilePasswordCell
            
            cell.annotationLabel.text = NSLocalizedString("Repeat Password", comment: "")
            cell.infoTextField.placeholder = "请再次填入新密码"
            
            return cell
                
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {

        case PasswordRow.CurrentPassword.rawValue:
            return 60
            
        case PasswordRow.NewPassword.rawValue:
            return 60
            
        case PasswordRow.RepeatPassword.rawValue:
            return 60
            
        default:
            return 0
        }
    }

}