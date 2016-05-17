//
//  TaskHomeViewController.swift
//  WisdriIS
//
//  Created by Allen on 16/4/20.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import PagingMenuController

class TaskHomeViewController: BaseViewController {
    
    private let currentUser = WISDataManager.sharedInstance().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = NSLocalizedString("Task List", comment: "")
        
        let storyboard = UIStoryboard(name: "TaskList", bundle: nil)
        
        let taskListForApproval = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        let taskListNormal = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        let taskListArchived = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        let taskListNotArchived = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        
        taskListForApproval.taskType = MaintenanceTaskType.ForApproval
        taskListForApproval.title = "待审批"

        taskListNormal.taskType = MaintenanceTaskType.Normal
        taskListNormal.title = "处理中"
        
        taskListArchived.taskType = MaintenanceTaskType.Archived
        taskListArchived.title = "已归档"
        
        taskListNotArchived.taskType = MaintenanceTaskType.NotArchived
        taskListNotArchived.title = "待归档"
        
        var viewControllers = [TaskListViewController]()
        
        // for test
        print(WISDataManager.sharedInstance().currentUser.roleCode)
        print(RoleCode.Operator)

        if WISDataManager.sharedInstance().currentUser.roleCode != WISDataManager.sharedInstance().roleCodes[RoleCode.Operator.rawValue] {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        let options = PagingMenuOptions()

//        options.menuItemMargin = 1
//        options.menuDisplayMode = .SegmentedControl
        options.menuDisplayMode = .Standard(widthMode: PagingMenuOptions.MenuItemWidthMode.Fixed(width: 60), centerItem: false, scrollingMode: PagingMenuOptions.MenuScrollingMode.ScrollEnabledAndBouces)
        
        options.menuItemMode = .Underline(height: 1.5, color: UIColor.yepTintColor(), horizontalPadding: 1.5, verticalPadding: 1.5)
        
        options.font = UIFont.systemFontOfSize(15)
        
        options.selectedFont = UIFont.systemFontOfSize(16)
        
        options.textColor = UIColor.yepGrayColor()
        options.selectedTextColor = UIColor.yepTintColor()
        
        let roleCodes = WISDataManager.sharedInstance().roleCodes
        if currentUser.roleCode == roleCodes[RoleCode.TechManager.rawValue]
            || currentUser.roleCode == roleCodes[RoleCode.FieldManager.rawValue] {
            viewControllers = [taskListForApproval, taskListNormal, taskListNotArchived, taskListArchived]
//            viewControllers = [taskListForApproval, taskListNormal]
            options.menuHeight = 40
        } else if currentUser.roleCode == roleCodes[RoleCode.FactoryManager.rawValue] {
            viewControllers = [taskListForApproval, taskListNormal]
            options.menuHeight = 40
        } else {
            viewControllers = [taskListNormal]
            options.menuHeight = 0
        }
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(viewControllers: viewControllers, options: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
