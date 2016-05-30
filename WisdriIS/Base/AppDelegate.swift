//
//  AppDelegate.swift
//  WisdriIS
//
//  Created by Allen on 16/2/19.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        SVProgressHUD.setForegroundColor(UIColor(white: 1, alpha: 1))
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.15, alpha: 0.85))
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        SVProgressHUD.setDefaultMaskType(.Clear)
        SVProgressHUD.setDefaultAnimationType(.Native)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didDisappearProgressHUD), name: SVProgressHUDDidDisappearNotification, object: nil)
        
        WISDataManager.sharedInstance().networkingDelegate = self

        self.window = UIWindow()
        self.window?.frame = UIScreen.mainScreen().bounds
        self.window?.backgroundColor = UIColor.wisBackgroundColor()
        self.window?.makeKeyAndVisible()
        
        if WISDataManager.sharedInstance().preloadArchivedUserInfo() {
            NSThread.sleepForTimeInterval(1.5)
            startMainStory()
        } else {
            NSThread.sleepForTimeInterval(1.0)
            self.window?.rootViewController = LoginViewController()
        }
        
        return true
    }
    
    func startMainStory() {
        // 获取用户信息详情
        WISDataManager.sharedInstance().updateCurrentUserDetailInformationWithCompletionHandler({ (completedWithNoError, error, classNameOfDataAsString, data) in
            if !completedWithNoError {
                SVProgressHUD.showErrorWithStatus("获取用户详细信息错误")
            }
        })
        
        userSegmentList.removeAll()
        currentClockStatus = .UndefinedClockStatus
        clockStatusValidated = false
        
        WISUserDefaults.setupSegment()
        WISUserDefaults.getCurrentUserClockStatus()
        WISUserDefaults.getWorkShift(NSDate())
        
        WISPushNotificationDataManager.sharedInstance().reloadDataWithUserName(WISDataManager.sharedInstance().currentUser.userName)
        
        // **
        // 注册 client ID, 用于Push Notification
        // **
        if let application : UIApplication? = UIApplication.sharedApplication() {
            WISPushNotificationService.sharedInstance().startPushNotificationServiceWithApplication(application)
        } else {
            WISPushNotificationService.sharedInstance().startPushNotificationServiceWithApplication(nil)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
        window?.rootViewController = rootViewController
    }
    
    func didDisappearProgressHUD() {
        SVProgressHUD.setDefaultMaskType(.Clear)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0;
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - 远程通知(推送)回调
    
    /** 远程通知注册成功委托   */
    /** NECESSARY!          */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        /// ***
        /// 注册deviceToken
        /// ***
        WISPushNotificationService.sharedInstance().registerDeviceToken(deviceToken);
    }
    
    /** 远程通知注册失败委托 NOT NECESSARY */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("\n>>>[DeviceToken Error]:%@\n\n",error.description);
    }
    
    // MARK: - APP运行中接收到通知(推送)处理
    
    /** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台)  NOT NECESSARY */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if UIApplicationState.Background == application.applicationState {
            application.applicationIconBadgeNumber += 1;
        }
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
        print("BadgeNumber after silent notification: \(application.applicationIconBadgeNumber)")
    }
}

extension AppDelegate: WISNetworkingDelegate {
    
    func networkStatusChangedTo(status: Int) {
        let application = UIApplication.sharedApplication()
        if (UIApplicationState.Inactive == application.applicationState)
            || (UIApplicationState.Active == application.applicationState) {
            
            switch status {
            case WISNetworkReachabilityStatus.ReachableViaWWAN.rawValue:
                if ((self.window?.rootViewController?.isKindOfClass(LoginViewController)) == false) {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showInfoWithStatus(NSLocalizedString("Networking Reachable via WWAN"))
                }
                break
                
            case WISNetworkReachabilityStatus.ReachableViaWiFi.rawValue:
                if ((self.window?.rootViewController?.isKindOfClass(LoginViewController)) == false) {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showInfoWithStatus(NSLocalizedString("Networking Reachable via Wi-Fi"))
                }
                break
                
            case WISNetworkReachabilityStatus.NotReachable.rawValue:
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showInfoWithStatus(NSLocalizedString("Networking Not Reachable"))
                break
                
            default:
                break
            }
        }
    }
}
