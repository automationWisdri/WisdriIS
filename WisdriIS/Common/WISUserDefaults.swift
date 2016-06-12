//
//  WISUserDefaults.swift
//  WisdriIS
//
//  Created by Allen on 3/16/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation

var userSegmentList = [Segment]()
var currentTask: WISMaintenanceTask?
var currentTaskOperations = [TaskOperation]()
var currentClockStatus: ClockStatus = .UndefinedClockStatus {
    didSet {
        clockStatusValidated = true
    }
}

var uploadingPlanDictionary = [String : NSProgress]()
var uploadingTaskDictionary = [Int : NSProgress]()
var clockStatusValidated = false

var workShifts = [String: Int]()

enum WorkShiftRange: Int {
    case Day = 0
    case Week
    case Month
    case Year
}

class WISUserDefaults {
    
    class func setupSegment() {
        guard userSegmentList.count <= 1 else {
            return
        }
        
        WISDataManager.sharedInstance().updateProcessSegmentWithCompletionHandler({ (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            userSegmentList.removeAll()
            userSegmentList.insert(segmentPlaceholder, atIndex: 0)
            if completedWithNoError {
                let segments: Dictionary = updatedData as! Dictionary<String, String>
                for (id, name) in segments {
                    let segment = Segment(id: id, name: name)
                    userSegmentList.append(segment)
                }
            } else {
                WISConfig.errorCode(error, customInformation: "获取工艺段失败")
            }
        })
    }
    
    class func getCurrentTaskOperations() {
        
        let validOperations = currentTask!.validOperations
        
        currentTaskOperations.removeAll()
        for (operationType, operationName) in validOperations {
            let row = TaskOperation()
            row.operationType = operationType
            row.operationName = operationName
            currentTaskOperations.append(row)
        }
        
    }
    
    class func getCurrentUserClockStatus() {
        WISDataManager.sharedInstance().updateCurrentClockStatusWithCompletionHandler { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                currentClockStatus = ClockStatus(rawValue: (data as! Int))!
                
            } else {
                // 无法获得任务操作方法，是否需要给用户提示？
//                WISConfig.errorCode(error, customInformation: "获取任务操作失败")
            }
        }
    }
    
    /// 获取排班记录
    /// 根据传入的日期和范围，获取日期当天、当周、当月、当年的排班记录
    class func getWorkShift(date: NSDate, range: WorkShiftRange) {
        
        var now: NSDate
        var recordNumber: Int
        
        switch range {
        case .Day:
            now = date
            recordNumber = 1
            
        case .Week:
            now = date.startOf(.Weekday)
            recordNumber = 7
            
        case .Month:
            now = date.startOf(.Month)
            recordNumber = now.monthDays
            
        case .Year:
            now = date.startOf(.Year)
            recordNumber = 365
        }

//        let previewsMonthDate = 1.months.agoFromDate(now)
//        let nextMonthDate = 1.months.fromNow()
//        let recordNumber = previewsMonthDate.monthDays + now.monthDays + nextMonthDate.monthDays

        WISDataManager.sharedInstance().updateWorkShiftsWithStartDate(now, recordNumber: recordNumber) { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                
                let shifts = data as! Array<Int>

                var i = 0
                for shift in shifts {
                    
                    let date = i.days.fromDate(now)
                    workShifts[date.toString()!] = shift
                    i += 1
                }
                
            } else {
                WISConfig.errorCode(error, customInformation: "查询排班记录失败")
            }
        }
    }

    class func getRelevantUserText(participants: NSMutableArray) -> String {
        
        let taskParticipants = participants
        var relevantUserText: String
        
        switch taskParticipants.count {
        case 0:
            relevantUserText = NSLocalizedString("No other engineers")
        default:
            relevantUserText = EMPTY_STRING
            for user in taskParticipants {
                
                if user as! NSObject == taskParticipants.lastObject as! WISUser {
                    relevantUserText = relevantUserText + user.fullName
                } else {
                    relevantUserText = user.fullName + "， " + relevantUserText
                }
            }
        }
        
        return relevantUserText
    }
    
    class func getRelevantUserText(participants: Array<WISUser>) -> String {
        
        let taskParticipants = participants
        var relevantUserText: String
        
        switch taskParticipants.count {
        case 0:
            relevantUserText = NSLocalizedString("No other engineers")
        default:
            relevantUserText = EMPTY_STRING
            for user in taskParticipants {
                if user == taskParticipants.last {
                    relevantUserText = relevantUserText + user.fullName
                } else {
                    relevantUserText = user.fullName + "， " + relevantUserText
                }
            }
        }
        
        return relevantUserText
    }
    
}