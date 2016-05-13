//
//  InspectionTaskForUploading.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation
import UIKit

public let InspectionTaskUploadingStateChangedNotification = "InspectionTaskUploadingStateChangedNotification"
public let InspectionTaskUploadingStateKey = "InspectionTaskUploadingState"
public let InspectionTaskDeviceIDKey = "InspectionTaskDeviceID"

/// Encoding Keys
private let inspectionTaskEncodingKey = "inspectionTask"
private let imagesNameEncodingKey = "imagesName"
private let isImagesUploadingCompletedEncodingKey = "isImagesUploadingCompleted"
private let uploadingStateEncodingKey = "uploadingState"


class InspectionTaskForUploading: NSObject, NSCoding {

    var inspectionTask = WISInspectionTask()
    // image names
    var imagesName = [String]()
    // image uploading complete symbol
    var isImagesUploadingCompleted = false
    var uploadingState = InspectionUploadingState.UploadingPending {
        didSet {
            let info = [InspectionTaskDeviceIDKey as NSString!:self.inspectionTask.device.deviceID as NSString!,
                        InspectionTaskUploadingStateKey as NSString!:self.uploadingState.rawValue as NSString!]
            
            let notification = NSNotification(name: InspectionTaskUploadingStateChangedNotification,
                                              object: self.uploadingState.rawValue as NSString!,
                                              userInfo: info)
            
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    var imageUploadingProgress = NSProgress() {
        didSet {
            let interior = self.uploadingState
            self.uploadingState = interior
        }
    }
    
    init(inspectionTask : WISInspectionTask, imagesName: [String], isImagesUploadingCompleted:Bool) {
        self.inspectionTask = inspectionTask.copy() as! WISInspectionTask
        self.imagesName = imagesName
        self.isImagesUploadingCompleted = isImagesUploadingCompleted
        self.uploadingState = .UploadingPending
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        self.inspectionTask = aDecoder.decodeObjectForKey(inspectionTaskEncodingKey) as! WISInspectionTask
        self.imagesName = aDecoder.decodeObjectForKey(imagesNameEncodingKey) as! [String]
        self.isImagesUploadingCompleted = aDecoder.decodeBoolForKey(isImagesUploadingCompletedEncodingKey)
        self.uploadingState = InspectionUploadingState(rawValue: (aDecoder.decodeObjectForKey(uploadingStateEncodingKey) as! String))!
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.inspectionTask, forKey: inspectionTaskEncodingKey)
        aCoder.encodeObject(self.imagesName, forKey: imagesNameEncodingKey)
        aCoder.encodeBool(self.isImagesUploadingCompleted, forKey: isImagesUploadingCompletedEncodingKey)
        aCoder.encodeObject(self.uploadingState.rawValue, forKey: uploadingStateEncodingKey)
    }
    
    class func arraySortForward (lhs: InspectionTaskForUploading, rhs: InspectionTaskForUploading) -> Bool {
        let result = lhs.inspectionTask.inspectionFinishedTime.compare(rhs.inspectionTask.inspectionFinishedTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedAscending {
            return true
        } else {
            return false
        }
    }
    
    class func arraySortBackward (lhs: InspectionTaskForUploading, rhs: InspectionTaskForUploading) -> Bool {
        let result = lhs.inspectionTask.inspectionFinishedTime.compare(rhs.inspectionTask.inspectionFinishedTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedDescending {
            return true
        } else {
            return false
        }
    }
    
    class func dictionarySortForward (lhs: (String, InspectionTaskForUploading), rhs: (String, InspectionTaskForUploading)) -> Bool {
        let lhsTask = lhs.1.inspectionTask
        let rhsTask = rhs.1.inspectionTask
        let result = lhsTask.inspectionFinishedTime.compare(rhsTask.inspectionFinishedTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedAscending {
            return true
        } else {
            return false
        }
    }
    
    class func dictionarySortBackward (lhs: (String, InspectionTaskForUploading), rhs: (String, InspectionTaskForUploading)) -> Bool {
        let lhsTask = lhs.1.inspectionTask
        let rhsTask = rhs.1.inspectionTask
        let result = lhsTask.inspectionFinishedTime.compare(rhsTask.inspectionFinishedTime)
        if NSComparisonResult.init(rawValue: result.rawValue) == NSComparisonResult.OrderedDescending {
            return true
        } else {
            return false
        }
    }
}


enum InspectionUploadingState: String {
    case Unknown = "Unknown"
    case UploadingPending = "Uploading Pending"
    case UploadingImages = "Uploading Images"
    case UploadingData = "Uploading Data"
    case UploadingCompleted = "Uploading Completed"
    case UploadingSuspended = "Uploading Suspended"
}
