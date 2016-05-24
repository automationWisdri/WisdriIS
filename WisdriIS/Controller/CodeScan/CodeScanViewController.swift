//
//  CodeScanViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/10/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation
import UIKit

public let QRCodeScanedSuccessfullyNotification = "QRCodeScanedSuccessfullyNotification"
public let codeScanNotificationTokenKey = "Token"

class CodeScanViewController: LBXScanViewController {
    /**
     @brief  state of flashlight
     */
    var isFlashlightOn:Bool = false
    
    // MARK: - 底部功能：开启闪光灯, 取消
    
    //底部显示的功能项
    var bottomItemsView:UIView?
    
    // Flash light button
    var btnFlashlight:UIButton = UIButton()
    // Cancel button
    var btnCancel:UIButton = UIButton()
    
    var isPushedFromParentController: Bool?
    var superViewController: UIViewController?
    var prefersHideStatuseBar = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        drawBottomItems()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.prefersHideStatuseBar
    }
    
    func drawBottomItems() {
        if (bottomItemsView != nil) {
            return;
        }
        
        let yMax = CGRectGetMaxY(self.view.frame) - CGRectGetMinY(self.view.frame)
        
        bottomItemsView = UIView(frame:CGRectMake( 0.0, yMax-100,self.view.frame.size.width, 100 ))
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view.addSubview(bottomItemsView!)
        
        let size = CGSizeMake(65, 87);
        
        self.btnFlashlight = UIButton()
        btnFlashlight.bounds = CGRectMake(0, 0, size.width, size.height)
        btnFlashlight.center = CGPointMake(CGRectGetWidth(bottomItemsView!.frame)/2, CGRectGetHeight(bottomItemsView!.frame)/2)
        btnFlashlight.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), forState:UIControlState.Normal)
        btnFlashlight.addTarget(self, action: #selector(self.toggleFlashlight), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.isPushedFromParentController = self.isMovingToParentViewController()
        
        if (self.isPushedFromParentController == true) {
            print("codeScanViewController is moving to parentViewController")
        } else {
            
            self.btnCancel = UIButton(type: UIButtonType.System)
            btnCancel.bounds = CGRectMake(0, 0, size.width+20, size.height)
            btnCancel.center = CGPointMake(CGRectGetWidth(bottomItemsView!.frame) * 1/9, CGRectGetHeight(bottomItemsView!.frame) * 1/2);
            btnCancel.titleLabel?.font = UIFont.boldSystemFontOfSize(UIFont.buttonFontSize())
            btnCancel.setTitle(NSLocalizedString("Cancel"), forState: .Normal)
            btnCancel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            btnCancel.addTarget(self, action:#selector(self.dismissCodeScanView), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        bottomItemsView?.addSubview(btnFlashlight)
        bottomItemsView?.addSubview(btnCancel)
        
        self.view .addSubview(bottomItemsView!)
    }
    
    //开关闪光灯
    func toggleFlashlight() {
        scanObj?.changeTorch();
        
        isFlashlightOn = !isFlashlightOn
        
        if isFlashlightOn {
            btnFlashlight.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), forState:UIControlState.Normal)
        } else {
            btnFlashlight.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), forState:UIControlState.Normal)
        }
    }
    
    func dismissCodeScanView() -> Void {
        self.dismissViewControllerAnimated(true) { 
            print("关闭扫码视图")
        }
    }
    
//    class func prepareToShowCodeScanView() -> (CodeScanViewController?, String?) {
//        var style = LBXScanViewStyle()
//        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
//        
//        let vc = CodeScanViewController();
//        vc.scanStyle = style
//        vc.modalPresentationStyle = UIModalPresentationStyle.FullScreen
//        vc.modalTransitionStyle = .CoverVertical
//        return (vc, vc.produceCodeScanNotificationToken())
//    }
    
    
    /// completion block excutes after view did appear
    class func performPresentToCodeScanViewController(superViewController:UIViewController, completion: (() -> Void)?) -> String! {
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        
        let viewController = CodeScanViewController();
        viewController.scanStyle = style
        viewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        viewController.modalTransitionStyle = .CoverVertical
        viewController.superViewController = superViewController
        viewController.prefersHideStatuseBar = true
        viewController.superViewController?.presentViewController(viewController, animated: true, completion: { 
            completion?()
        })
        
        return viewController.produceCodeScanNotificationToken()
    }
    
    
    class func performPushToCodeScanViewController(superViewController:UIViewController, completion: (() -> Void)?) -> String! {
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        
        let viewController = CodeScanViewController();
        viewController.scanStyle = style
        viewController.superViewController = superViewController
        viewController.prefersHideStatuseBar = false
        viewController.hidesBottomBarWhenPushed = true

        superViewController.navigationController?.pushViewController(viewController, animated: true)
        completion?()
        
        return viewController.produceCodeScanNotificationToken()
    }
    
    
    private var codeScanNotificationToken:String?
    
    func produceCodeScanNotificationToken() -> String! {
        self.codeScanNotificationToken = NSUUID.init().UUIDString
        return self.codeScanNotificationToken
    }
    
    override func handleCodeResult(arrayResult:[LBXScanResult]) {
        let result = arrayResult[0]
        
        let notification = NSNotification(name: QRCodeScanedSuccessfullyNotification,
                                          object: result.strScanned,
                                          userInfo: [codeScanNotificationTokenKey as NSString!:self.codeScanNotificationToken!])
        
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        if self.isPushedFromParentController == true {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissCodeScanView()
        }
        
        // super.handleCodeResult(arrayResult)
    }
}