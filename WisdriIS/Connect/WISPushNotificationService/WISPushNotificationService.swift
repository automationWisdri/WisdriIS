//
//  WISPushNotificationService.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/6/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation
import SVProgressHUD

let OnLineNotificationReceivedNotification = "OnLineNotificationReceivedNotification"

/// contents below are parameters for AppName:WisdriIS-Dev with getui ID titanwjw
//let kGtAppId:String = "GJg6Sb5zUk8NHl8VQUs1Y7"
//let kGtAppKey:String = "K4rRQSX3JF7Wxbr4enXEA3"
//let kGtAppSecret:String = "midbPTq37v9jQmPAtuO7j6"

/// contents below are parameters for AppName:WisdriIS, which is actually used by the server.
let kGtAppId:String = "NimhmxOsRq830FWRlJrcM7"
let kGtAppKey:String = "Zd4ul4XyWRAeDrddhwJFTA"
let kGtAppSecret:String = "3KMPZCZ5z66NSE4y6nKtZ2"

class WISPushNotificationService: NSObject, GeTuiSdkDelegate {
    
    static func sharedInstance() -> WISPushNotificationService { return WISPushNotificationService.sharedPushNotificationService }
    static var counter : Int = 0;
    private static let sharedPushNotificationService = WISPushNotificationService()
    private override init() {}
    
    func startPushNotificationServiceWithApplication(application : UIApplication?) {
        // 注册远程通知服务
        // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
        GeTuiSdk.startSdkWithAppId(kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self);
        
        // 注册Apns
        self.registerUserNotification(application);
    }
    
    func registerDeviceToken(deviceToken:NSData) {
        var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"));
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        GeTuiSdk.registerDeviceToken(token);
        
        NSLog("\n>>>[DeviceToken Success]:%@\n\n",token);
    }
    
    // MARK: - 用户通知(推送) _自定义方法
    
    /** 注册用户通知(推送) */
    private func registerUserNotification(application: UIApplication?) {
        let result = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch)
        if (result != NSComparisonResult.OrderedAscending) {
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let userSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(userSettings)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        }
    }
    
    
    // MARK: - GeTuiSdkDelegate
    
    /** SDK启动成功返回cid */
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        // [4-EXT-1]: 个推SDK已注册，返回clientId
        NSLog("\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
        
        WISDataManager.sharedInstance().submitUserClientID(clientId) { (completedWithNoError, error) in
            // do nothing
        }
    }
    
    /** SDK遇到错误回调 */
    func GeTuiSdkDidOccurError(error: NSError!) {
        // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
        NSLog("\n>>>[GeTuiSdk error]:%@\n\n", error.localizedDescription);
    }
    
    /** SDK收到sendMessage消息回调 */
    func GeTuiSdkDidSendMessage(messageId: String!, result: Int32) {
        // [4-EXT]:发送上行消息结果反馈
        let msg:String = "sendmessage=\(messageId),result=\(result)";
        NSLog("\n>>>[GeTuiSdk DidSendMessage]:%@\n\n",msg);
    }
    
    func GeTuiSdkDidReceivePayloadData(payloadData: NSData!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        
        var payloadMsg = "";
        if((payloadData) != nil) {
            payloadMsg = String.init(data: payloadData, encoding: NSUTF8StringEncoding)!;
        }
        
        let newNotification = WISPushNotification.init(notificationBody: payloadMsg, notificationReceivedDateTime: NSDate.init())
        let notificationIndex = WISPushNotificationDataManager.sharedInstance().addPushNotification(newNotification)
        
        if !offLine {
            // SVProgressHUD.setDefaultMaskType(.None)
            // SVProgressHUD.showInfoWithStatus(payloadMsg)
            let alert = UIAlertView.init(title: NSLocalizedString("Notification", comment: ""), message: payloadMsg, delegate: nil, cancelButtonTitle: NSLocalizedString("Confirm", comment: ""))
            alert.show()
            
            NSNotificationCenter.defaultCenter().postNotificationName(OnLineNotificationReceivedNotification, object: String(notificationIndex))
        }
        
        let msg:String = "Receive Payload: \(payloadMsg), taskId:\(taskId), messageId:\(msgId)";
        
        NSLog("\n>>>[GeTuiSdk DidReceivePayload]:%@\n\n",msg);
        
        // if let application : UIApplication? = UIApplication.sharedApplication() {
        //     application?.applicationIconBadgeNumber -= 1
        //     print("BadgeNumber after payload data has been received: \(application?.applicationIconBadgeNumber)")
        // }
    }
}



