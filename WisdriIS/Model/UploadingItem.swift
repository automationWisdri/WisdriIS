//
//  TaskPlanUploadingList.swift
//  WisdriIS
//
//  Created by Allen on 5/30/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation

public let UploadingNotification = "UploadingNotification"
public let UploadingStateKey = "UploadingState"
public let TaskIDKey = "TaskID"

enum UploadingState: String {
    case UploadingStart = "Uploading Start"
    case UploadingPending = "Uploading Pending"
    case UploadingCompleted = "Uploading Completed"
}