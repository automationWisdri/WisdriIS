//
//  OperationType.swift
//  WisdriIS
//
//  Created by Allen on 16/3/21.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation

class TaskOperation {
    
    internal var operationType: String
    internal var operationName: String
    
    init() {
        operationType = ""
        operationName = ""
    }
    
    
    init(operationType: String, operationName: String) {
        self.operationType = operationType
        self.operationName = operationName
    }
    
}