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

var clockStatusValidated = false

var workShifts = [String: Int]()

class WISUserDefaults {
    
    class func setupSegment() {
        guard userSegmentList.isEmpty == true else {
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
                // 待处理
            }
        }
    }
    
    class func getWorkShift(date: NSDate) {
        
//        let now = date.startOf(.Month)
        let now = date.startOf(.Year)
//        let previewsMonthDate = 1.months.agoFromDate(now)
//        let nextMonthDate = 1.months.fromNow()
//        let recordNumber = previewsMonthDate.monthDays + now.monthDays + nextMonthDate.monthDays
//        print("请求查询 \(recordNumber) 条记录")
        WISDataManager.sharedInstance().updateWorkShiftsWithStartDate(now, recordNumber: 365) { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                
                let shifts = data as! Array<Int>
                
//                workShifts.removeAll()
//                print("查询到 \(shifts.count) 条记录")
                var i = 0
                for shift in shifts {
                    
                    let date = i.days.fromDate(now)
                    workShifts[date.toString()!] = shift
//                    print("第 \(i) 条记录：\(date.toString()!), \(workShifts[date.toString()!])")

                    i += 1
                }
                
            } else {
                // 待修改
            }
        }
    }

    class func getRelevantUserText(participants: NSMutableArray) -> String {
        
        let taskParticipants = participants
        var relevantUserText: String
        
        switch taskParticipants.count {
        case 0:
            relevantUserText = "无其他参与人员"
        default:
            relevantUserText = ""
            for user in taskParticipants {
                
                if user as! NSObject == taskParticipants.lastObject as! WISUser {
                    relevantUserText = relevantUserText + user.fullName
                } else {
                    relevantUserText = user.fullName + "， " + relevantUserText
                }
            }
//            relevantUserText = "参与人员:  " + relevantUserText
        }
        
        return relevantUserText
    }
    
}