//
//  TaskState.swift
//  WisdriIS
//
//  Created by Allen on 5/24/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation

/*
    /// 技术主管
    TechManager = 0,
    /// 厂级负责人
    FactoryManager = 1,
    /// 前方部长
    FieldManager = 2,
    /// 值班经理
    DutyManager = 3,
    /// 工程师
    Engineer = 4,
    /// 生产操作人员
    Operator = 5,
    /// 电工
    Technician = 6,
*/
enum TaskStateForOperator: String {
    case Processing = "处理中"
    case Pending = "待处理"
    case ForEvaluate = "待评价"
}

enum TaskStateForEngineer: String {
    case Pending = "等待接单."
    case ForSubmit = "提交维保方案."
    case ForTechApprove = "技术主管审批."
    case ForManagerApprove = "厂级负责人审批."
    case Processing = "维保过程."
    case ForAffirm = "任务完成待确认."
    case PassOn = "转单中"
    case PassOnForAccept = "等待接单"
}

enum TaskStateForManager: String {
    case Finish = "已完成"
}