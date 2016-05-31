//
//  TaskListCustomizeViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/31/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskListCustomizeViewController: BaseViewController {
    
    var taskListCustomizeTableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskListCustomizeTableView = UITableView(frame: CGRectMake(0, 0, 300, 300), style: .Plain)
        taskListCustomizeTableView.opaque = false
        taskListCustomizeTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(taskListCustomizeTableView)
        // self.view.backgroundColor = UIColor.wisTintColor()
        
        self.view.opaque = false
        self.view.backgroundColor = UIColor.clearColor()
    }
}


