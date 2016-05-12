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
var currentClockStatus = 0
var workShifts = [String: Int]()

class WISUserDefaults {

//    var userSegmentList: [Segment] = {
//        var userSegmentList = [Segment]()
//        WISDataManager.sharedInstance().updateProcessSegmentWithCompletionHandler({ (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
//            userSegmentList.insert(generalSkill, atIndex: 0)
//            if completedWithNoError {
//                let segments: Dictionary = updatedData as! Dictionary<String, String>
//                for (id, name) in segments {
//                    let skill = Segment(id: id, name: name)
//                    userSegmentList.append(skill)
//                }
//            }
//        })
//        return userSegmentList
//    }()
    
    class func setupSegment() {
        WISDataManager.sharedInstance().updateProcessSegmentWithCompletionHandler({ (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            userSegmentList.removeAll()
            userSegmentList.insert(generalSkill, atIndex: 0)
            if completedWithNoError {
                let segments: Dictionary = updatedData as! Dictionary<String, String>
                for (id, name) in segments {
                    let skill = Segment(id: id, name: name)
                    userSegmentList.append(skill)
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
//            print(row)
            currentTaskOperations.append(row)
        }
        
    }
    
    class func getCurrentUserClockStatus() {
        WISDataManager.sharedInstance().updateCurrentClockStatusWithCompletionHandler { (completedWithNoError, error, classNameOfDataAsString, data) in
            if completedWithNoError {
                
                currentClockStatus = data as! Int
                
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

}