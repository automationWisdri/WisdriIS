//
//  LoginViewController.swift
//  WisdriIS
//
//  Created by Allen on 1/22/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit
import KeyboardMan

class LoginViewController: UIViewController {

    var backgroundImageView: UIImageView?
    var frostedView: UIVisualEffectView?
    var userNameTextField: UITextField?
    var passwordTextField: UITextField?
    var loginButton: UIButton?
    
    var singleTap: UITapGestureRecognizer?
    let keyboardMan = KeyboardMan()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.backgroundImageView = UIImageView(image: UIImage(named: "login-bg-iphone-3.jpg"))
        self.backgroundImageView!.frame = self.view.frame
        self.backgroundImageView!.contentMode = .ScaleToFill
        self.view.addSubview(self.backgroundImageView!)
        backgroundImageView!.alpha = 0
        
        frostedView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        frostedView!.frame = self.view.frame
        self.view.addSubview(frostedView!)
        
        let vibrancy = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.userInteractionEnabled = true
        vibrancyView.frame = frostedView!.frame
        frostedView!.contentView.addSubview(vibrancyView)
        
        let wisLabel = UILabel()
        wisLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 40)!
        wisLabel.text = "WISDRI"
        vibrancyView.contentView.addSubview(wisLabel)
        wisLabel.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(vibrancyView)
            make.top.equalTo(vibrancyView).offset(130)
        }
        
        let wisSummaryLabel = UILabel()
        wisSummaryLabel.font = wisFont(23)
        wisSummaryLabel.text = "工业云服务"
        vibrancyView.contentView.addSubview(wisSummaryLabel)
        wisSummaryLabel.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(vibrancyView)
            make.top.equalTo(wisLabel.snp_bottom).offset(8)
        }
        
        self.userNameTextField = UITextField()
        self.userNameTextField!.textColor = UIColor.whiteColor()
        self.userNameTextField!.backgroundColor = UIColor(white: 1, alpha: 0.1)
        self.userNameTextField!.font = wisFont(15)
        self.userNameTextField!.layer.cornerRadius = 3
        self.userNameTextField!.layer.borderWidth = 0.5
        self.userNameTextField!.keyboardType = .ASCIICapable
        self.userNameTextField!.returnKeyType = .Next
        self.userNameTextField!.layer.borderColor = UIColor(white: 1, alpha: 0.8).CGColor
        self.userNameTextField!.placeholder = "用户名"
        self.userNameTextField!.clearButtonMode = .Always
        self.userNameTextField!.autocapitalizationType = .None
        self.userNameTextField!.autocorrectionType = .No
        self.userNameTextField!.tag = 1
        self.userNameTextField?.delegate = self
        
        let userNameIconImageView = UIImageView(image: UIImage(named: "ic_account_circle")!.imageWithRenderingMode(.AlwaysTemplate))
        userNameIconImageView.frame = CGRectMake(0, 0, 34, 22)
        userNameIconImageView.tintColor = UIColor.whiteColor()
        userNameIconImageView.contentMode = .ScaleAspectFit
        self.userNameTextField!.leftView = userNameIconImageView
        self.userNameTextField!.leftViewMode = .Always
        
        vibrancyView.contentView.addSubview(self.userNameTextField!)
        
        self.userNameTextField!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(wisSummaryLabel.snp_bottom).offset(125)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }

        self.passwordTextField = UITextField()
        self.passwordTextField!.textColor = UIColor.whiteColor()
        self.passwordTextField!.backgroundColor = UIColor(white: 1, alpha: 0.1)
        self.passwordTextField!.font = wisFont(15)
        self.passwordTextField!.layer.cornerRadius = 3
        self.passwordTextField!.layer.borderWidth = 0.5
        self.passwordTextField!.keyboardType = .ASCIICapable
        self.passwordTextField!.returnKeyType = .Done
        self.passwordTextField!.secureTextEntry = true
        self.passwordTextField!.layer.borderColor = UIColor(white: 1, alpha: 0.8).CGColor
        self.passwordTextField!.placeholder = "密码"
        self.passwordTextField!.clearButtonMode = .Always
        self.passwordTextField!.tag = 2
        
        let passwordIconImageView = UIImageView(image: UIImage(named: "ic_lock")!.imageWithRenderingMode(.AlwaysTemplate))
        passwordIconImageView.frame = CGRectMake(0, 0, 34, 22)
        passwordIconImageView.contentMode = .ScaleAspectFit
        userNameIconImageView.tintColor = UIColor.whiteColor()
        self.passwordTextField!.leftView = passwordIconImageView
        self.passwordTextField!.leftViewMode = .Always
        self.passwordTextField?.delegate = self
        
        vibrancyView.contentView.addSubview(self.passwordTextField!)
        
        self.passwordTextField!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.userNameTextField!.snp_bottom).offset(15)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
        
        self.loginButton = UIButton()
        self.loginButton!.setTitle("登  录", forState: .Normal)
        self.loginButton!.titleLabel!.font = wisFont(20)
        self.loginButton!.layer.cornerRadius = 3
        self.loginButton!.layer.borderWidth = 0.5
        self.loginButton!.layer.borderColor = UIColor(white: 1, alpha: 0.8).CGColor
        vibrancyView.contentView.addSubview(self.loginButton!)
        
        self.loginButton!.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.passwordTextField!.snp_bottom).offset(20)
            make.centerX.equalTo(vibrancyView)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
        
        self.loginButton?.addTarget(self, action: #selector(LoginViewController.loginClick(_:)), forControlEvents: .TouchUpInside)
        
        let forgetPasswordLabel = UILabel()
        forgetPasswordLabel.alpha = 0.5
        forgetPasswordLabel.font = wisFont(12)
        forgetPasswordLabel.text = "忘记密码了?"
        
        vibrancyView.contentView.addSubview(forgetPasswordLabel)
        
        forgetPasswordLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.loginButton!.snp_bottom).offset(14)
            make.right.equalTo(self.loginButton!)
        }
        
        let footLabel = UILabel()
        footLabel.alpha = 0.5
        footLabel.font = wisFont(12)
        footLabel.text = "© 2016 WISDRI"
        
        vibrancyView.contentView.addSubview(footLabel)
        
        footLabel.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(vibrancyView).offset(-20)
            make.centerX.equalTo(vibrancyView)
        }
        
        self.view.userInteractionEnabled = true
        
        singleTap = UITapGestureRecognizer.init(target: self, action: #selector(LoginViewController.singleTapped(_:)))
        self.view.addGestureRecognizer(singleTap!)
        
        #if (arch(x86_64) || arch(i386)) && os(iOS)
            
        #else
            
        keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            print("appear \(appearPostIndex), \(keyboardHeight), \(keyboardHeightIncrement)")
            if let strongSelf = self {
                
                strongSelf.view.frame.origin.y -= keyboardHeightIncrement
                strongSelf.view.frame.size.height += keyboardHeightIncrement
                strongSelf.view.layoutIfNeeded()
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            print("disappear \(keyboardHeight)\n")
            if let strongSelf = self {
                strongSelf.view.frame.origin.y += keyboardHeight
                strongSelf.view.frame.size.height -= keyboardHeight
                strongSelf.view.layoutIfNeeded()
            }
        }
        
        #endif
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(2) { () -> Void in
            self.backgroundImageView!.alpha = 1
        }
        UIView.animateWithDuration(20) { () -> Void in
            self.backgroundImageView?.frame = CGRectMake(-1*( 1000 - SCREEN_WIDTH )/2, 0, SCREEN_HEIGHT+500, SCREEN_HEIGHT+500)
        }
    }
    
    func singleTapped(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func loginClick(sender: UIButton){
        
        var userName: String?
        var password: String?
        
        if self.userNameTextField!.text?.Length > 0 {
            userName = self.userNameTextField!.text! 
        }
        else{
            self.userNameTextField!.becomeFirstResponder()
            return
        }
        
        if self.passwordTextField!.text?.Length > 0 {
            password = self.passwordTextField!.text!
        }
        else{
            self.passwordTextField!.becomeFirstResponder()
            return
        }
        SVProgressHUD.showWithStatus("正在登陆")
        
        WISDataManager.sharedInstance().signInWithUserName(userName, andPassword: password, completionHandler: { (completedWithNoError, error) -> Void in
            if (completedWithNoError) {
                SVProgressHUD.showSuccessWithStatus("登陆成功")
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    appDelegate.startMainStory()
                    // 待修改
                    WISDataManager.sharedInstance().updateCurrentUserDetailInformationWithCompletionHandler({ (completedWithNoError, error, classNameOfDataAsString, data) in
                        if !completedWithNoError {
                            SVProgressHUD.showErrorWithStatus("获取用户详细信息错误")
                        }
                    })
                    WISUserDefaults.setupSegment()
                    WISUserDefaults.getCurrentUserClockStatus()
                    WISUserDefaults.getWorkShift(NSDate())
                    
                }
                // **
                // 注册 client ID, 用于Push Notification
                // **
                if let application : UIApplication? = UIApplication.sharedApplication() {
                    WISPushNotificationService.sharedInstance().startPushNotificationServiceWithApplication(application)
                } else {
                    WISPushNotificationService.sharedInstance().startPushNotificationServiceWithApplication(nil)
                }
                SVProgressHUD.dismiss()
            } else {
                
                guard let errorCode = WISErrorCode(rawValue: error.code) else {
                    SVProgressHUD.showErrorWithStatus("数据错误")
                    return
                }
                
                switch errorCode {
                    
                case .ErrorCodeSignInUserNotExist:
                    
                    SVProgressHUD.showErrorWithStatus("用户不存在")
                    self.userNameTextField!.becomeFirstResponder()
                    return
                    
                case .ErrorCodeSignInWrongPassword:
                    
                    SVProgressHUD.showErrorWithStatus("密码错误")
                    self.passwordTextField!.becomeFirstResponder()
                    return
                    
                default:
                    
                    SVProgressHUD.showErrorWithStatus("登陆失败")
                    return
                }
            }
        })
    }
    
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == self.userNameTextField) {
            self.passwordTextField!.becomeFirstResponder()
            return true
        }
        else if (textField == self.passwordTextField) {
            self.passwordTextField!.resignFirstResponder()
            loginClick(self.loginButton!)
            return true
        } else {
            return false
        }
    }
}
