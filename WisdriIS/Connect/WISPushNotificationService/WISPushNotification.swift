//
//  WISPushNotification.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation


/// Encoding Keys
private let notificationContentEncodingKey = "WISPushNotification.notificationContent"
private let notificationTaskIDEncodingKey = "WISPushNotification.notificationTaskID"
private let notificationReceivedDateTimeEncodingKey = "WISPushNotification.notificationReceivedDateTime"

class WISPushNotification: NSObject, NSCoding {
    
    var notificationContent: String = ""
    var notificationTaskID: String = ""
    var notificationReceivedDateTime: NSDate = NSDate.init()
    
    init(notificationBody : String, notificationReceivedDateTime: NSDate) {
        let contents = notificationBody.componentsSeparatedByString(":")
        self.notificationTaskID = contents[0]
        self.notificationContent = contents[1]
        self.notificationReceivedDateTime = notificationReceivedDateTime
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        self.notificationContent = aDecoder.decodeObjectForKey(notificationContentEncodingKey) as! String
        self.notificationTaskID = aDecoder.decodeObjectForKey(notificationTaskIDEncodingKey) as! String
        self.notificationReceivedDateTime = aDecoder.decodeObjectForKey(notificationReceivedDateTimeEncodingKey) as! NSDate
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.notificationContent, forKey: notificationContentEncodingKey)
        aCoder.encodeObject(self.notificationTaskID, forKey: notificationTaskIDEncodingKey)
        aCoder.encodeObject(self.notificationReceivedDateTime, forKey: notificationReceivedDateTimeEncodingKey)
    }
    
    static let arrayForwardSorter: (WISPushNotification, WISPushNotification) -> Bool = { (lhs, rhs) -> Bool in
        let result = lhs.notificationReceivedDateTime.compare(rhs.notificationReceivedDateTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedAscending {
            return true
        } else {
            return false
        }
    }
    
    static let arrayBackwardSorter: (WISPushNotification, WISPushNotification) -> Bool = { (lhs, rhs) -> Bool in
        let result = lhs.notificationReceivedDateTime.compare(rhs.notificationReceivedDateTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedDescending {
            return true
        } else {
            return false
        }
    }
    
    
    class func dictionarySortForward (lhs: (String, WISPushNotification), rhs: (String, WISPushNotification)) -> Bool {
        let lhsNotificationReceivedDateTime = lhs.1.notificationReceivedDateTime
        let rhsNotificationReceivedDateTime = rhs.1.notificationReceivedDateTime
        let result = lhsNotificationReceivedDateTime.compare(rhsNotificationReceivedDateTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedAscending {
            return true
        } else {
            return false
        }
    }
    
    class func dictionarySortBackward (lhs: (String, WISPushNotification), rhs: (String, WISPushNotification)) -> Bool {
        let lhsNotificationReceivedDateTime = lhs.1.notificationReceivedDateTime
        let rhsNotificationReceivedDateTime = rhs.1.notificationReceivedDateTime
        let result = lhsNotificationReceivedDateTime.compare(rhsNotificationReceivedDateTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedDescending {
            return true
        } else {
            return false
        }
    }
}
