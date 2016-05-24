//
//  WISPushNotificationDataManager.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation

private let defaultLocalPushNotificationArchivingStorageDirectoryKey = "defaultLocalPushNotificationArchivingStorageDirectory"

class WISPushNotificationDataManager {
    
    // MARK: Shared Instances
    static func sharedInstance() -> WISPushNotificationDataManager { return WISPushNotificationDataManager.sharedPushNotificationDataManagerInstance }
    private static let sharedPushNotificationDataManagerInstance = WISPushNotificationDataManager(archivingStorageFolderName: "PushNotificationArchivingCache")
    
    private var localPushNotificationArchivingStorageDirectories = [String : String]()
    
    var pushNotifications = [WISPushNotification]()
    
    private init(archivingStorageFolderName folderName: String) {
        print("WISPushNotificationDataManager initializing!")
        
        setDefaultLocalArchivingStorageDirectory(folderName)
        
        let archivingFilesFullPath = filesFullPathIn(Directory: defaultLocalPushNotificationArchivingStorageDirectory)
        
        if archivingFilesFullPath.count > 0 {
            for fileFullPath in archivingFilesFullPath {
                pushNotifications.append(NSKeyedUnarchiver.unarchiveObjectWithFile(fileFullPath) as! WISPushNotification)
            }
        }
        
        if pushNotifications.count > 0 {
            pushNotifications.sortInPlace(WISPushNotification.arrayForwardSorter)
        }
    }
    
    deinit {
       
    }
    
    // MARK: -
    
    private func notificationListContains(notification: WISPushNotification) -> Bool {
        guard self.pushNotifications.count > 0 else {
            return false
        }
        
        for notif in self.pushNotifications {
            if notif.notificationContent == notification.notificationContent && notif.notificationReceivedDateTime.isEqualToDate(notification.notificationReceivedDateTime) {
                return true
            }
        }
        return false
    }
    
    
    func addPushNotification(notification: WISPushNotification) -> Int {
        // 如果是重复的通知项目, 就不再添加
        guard !notificationListContains(notification) else {
            return -1
        }
        
        self.pushNotifications.append(notification)
        
        let fileName = notification.notificationContent + notification.notificationReceivedDateTime.toDateStringWithSeparator("") + ".notificationArchive"
        let fileFullPath = defaultLocalPushNotificationArchivingStorageDirectory.stringByAppendingPathComponent(fileName)
        NSKeyedArchiver.archiveRootObject(notification, toFile: fileFullPath)
        
        print("add notification: \(notification.notificationContent) to notification list.")
        
        return self.pushNotifications.count - 1
    }
    
    func removePushNotificationByIndex(index: Int = 0) -> Bool {
        if pushNotifications.count > 0 && index < pushNotifications.count {
            let fileName = self.pushNotifications[index].notificationContent + self.pushNotifications[index].notificationReceivedDateTime.toDateStringWithSeparator("") + ".notificationArchive"
            let fileFullPath = defaultLocalPushNotificationArchivingStorageDirectory.stringByAppendingPathComponent(fileName)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(fileFullPath)
            } catch {
                // do nothing
            }
            pushNotifications.removeAtIndex(index)
            print("remove notification index: \(index) from notification list.")
            
            return true
            
        } else {
            return false
        }
    }
    
    // MARK: - storage support method
    private func setDefaultLocalArchivingStorageDirectory(folderName: String) -> Void {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentDirectory = documentDirectories.first
        let archivingStorageDirectory = documentDirectory?.stringByAppendingPathComponent(folderName)
        
        if (!(NSFileManager.defaultManager().fileExistsAtPath(archivingStorageDirectory!))) {
            do {
                try  NSFileManager.defaultManager().createDirectoryAtPath(archivingStorageDirectory!, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // do nothing
            }
        }
        self.localPushNotificationArchivingStorageDirectories[defaultLocalPushNotificationArchivingStorageDirectoryKey] = archivingStorageDirectory
    }
    
    var defaultLocalPushNotificationArchivingStorageDirectory: String {
        return self.localPushNotificationArchivingStorageDirectories[defaultLocalPushNotificationArchivingStorageDirectoryKey]!
    }
    
    func defaultLocalArchivingStoragePathWithArchivingFileName(fileName: String) -> String {
        return self.defaultLocalPushNotificationArchivingStorageDirectory.stringByAppendingPathComponent(fileName)
    }
    
    func filesFullPathIn(Directory directory: String) -> [String] {
        var filesName = [String]()
        var filesFullPath = [String]()
        do {
            try filesName = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory)
        } catch {
            // do nothing
        }
        
        if filesName.count > 0 {
            for fileName in filesName {
                let fileFullPath = directory.stringByAppendingPathComponent(fileName)
                if NSFileManager.defaultManager().fileExistsAtPath(fileFullPath) {
                    filesFullPath.append(fileFullPath)
                }
            }
        }
        return filesFullPath
    }
}
