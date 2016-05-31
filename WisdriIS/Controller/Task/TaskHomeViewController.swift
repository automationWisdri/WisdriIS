//
//  TaskHomeViewController.swift
//  WisdriIS
//
//  Created by Allen on 16/4/20.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import PagingMenuController
import SVProgressHUD

class TaskHomeViewController: BaseViewController {
    
    var viewControllers = [TaskListViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n====================\nTaskHomeViewController did load\n====================\n")

        // Do any additional setup after loading the view.
        title = NSLocalizedString("Task List", comment: "")
        
        guard let currentUser = WISDataManager.sharedInstance().currentUser else {
            SVProgressHUD.showErrorWithStatus("获取登录信息失败\n请检查网络情况后重新登录")
            delay(1.5, work: {
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    appDelegate.window?.rootViewController = LoginViewController()
                }
            })
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleTaskUploadingNotification(_:)), name: MaintenanceTaskUploadingNotification, object: nil)
        
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
        
//        var viewControllers = [TaskListViewController]()
        
        // for test
        print("RoleCodes: " + WISDataManager.sharedInstance().roleCodes.description)
        print(WISDataManager.sharedInstance().currentUser.roleCode)
        print(currentUser.roleCode)

        if currentUser.roleCode != WISDataManager.sharedInstance().roleCodes[RoleCode.Operator.rawValue] {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        let options = PagingMenuOptions()

        options.menuDisplayMode = .Standard(widthMode: PagingMenuOptions.MenuItemWidthMode.Fixed(width: 60), centerItem: false, scrollingMode: PagingMenuOptions.MenuScrollingMode.ScrollEnabledAndBouces)
        
        options.menuItemMode = .Underline(height: 1.5, color: UIColor.wisTintColor(), horizontalPadding: 1.5, verticalPadding: 1.5)
        
        options.font = UIFont.systemFontOfSize(15)
        
        options.selectedFont = UIFont.systemFontOfSize(16)
        options.lazyLoadingPage = .Three
        
        options.textColor = UIColor.wisGrayColor()
        options.selectedTextColor = UIColor.wisTintColor()
        
        let roleCodes = WISDataManager.sharedInstance().roleCodes
        if currentUser.roleCode == roleCodes[RoleCode.TechManager.rawValue]
            || currentUser.roleCode == roleCodes[RoleCode.FieldManager.rawValue] {
            viewControllers = [taskListForApproval, taskListNormal, taskListNotArchived, taskListArchived]
            options.menuHeight = 40
        } else if currentUser.roleCode == roleCodes[RoleCode.FactoryManager.rawValue] {
            viewControllers = [taskListForApproval, /*taskListNormal*/]
            options.menuHeight = 0
        } else {
            viewControllers = [taskListNormal]
            options.menuHeight = 0
        }
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(viewControllers: viewControllers, options: options)
        
        pagingMenuController.delegate = self
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleNotification(_:)), name: NewTaskSubmittedSuccessfullyNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleNotification(_:)), name: OnLineNotificationReceivedNotification, object: nil)
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        let currentViewController = pagingMenuController.currentViewController as! TaskListViewController
        
        currentViewController.taskTableView.scrollsToTop = true
        currentViewController.getTaskList(currentViewController.taskType!, silentMode: true)
        
        print("\n====================\nTaskHomeViewController did Appear\n====================\n")
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NewTaskSubmittedSuccessfullyNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OnLineNotificationReceivedNotification, object: nil)
        
        print("\n====================\nTaskHomeViewController did Disappear\n====================\n")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MaintenanceTaskUploadingNotification, object: nil)
        print("Notification \(MaintenanceTaskUploadingNotification) deregistered in \(self) while deiniting")
        print("\n====================\nTaskHomeViewController deinited\n====================\n")
    }
    
    // MARK: - Notification handler
    
    func handleNotification(notification:NSNotification) -> Void {
        
        switch notification.name {
        case OnLineNotificationReceivedNotification, NewTaskSubmittedSuccessfullyNotification:
            let pagingMenuController = self.childViewControllers.first as! PagingMenuController
            let currentViewController = pagingMenuController.currentViewController as! TaskListViewController
            currentViewController.getTaskList(currentViewController.taskType!, silentMode: true)
            break
            
        default:
            break
        }
    }
    
    @objc func handleTaskUploadingNotification(notification: NSNotification) {
        guard let state = notification.object else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            switch state as! String {
            case UploadingState.UploadingStart.rawValue:
                if uploadingTaskDictionary.count > 0 {
                    self.navigationItem.title = "任务上传..."
                }
            case UploadingState.UploadingPending.rawValue:
                guard uploadingTaskDictionary.count > 0 else {
                    return
                }
                
                var totalUploadingPercentage: Int = 0
                
                for (_, progress) in uploadingTaskDictionary {
                    totalUploadingPercentage += Int(progress.fractionCompleted * 100)
                }
                
                totalUploadingPercentage = totalUploadingPercentage / uploadingTaskDictionary.count
                
                self.navigationItem.title = "任务上传...(\(totalUploadingPercentage)%)"
                
            case UploadingState.UploadingCompleted.rawValue:
                
                let pagingMenuController = self.childViewControllers.first as! PagingMenuController
                let currentViewController = pagingMenuController.currentViewController as! TaskListViewController
                currentViewController.getTaskList(currentViewController.taskType!, silentMode: true)
                
                if uploadingTaskDictionary.count == 0 {
                    self.navigationItem.title = NSLocalizedString("Task List", comment: "")
                }
                
            default:
                return
            }
        }
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

    // MARK: - extension - PagingMenuControllerDelegate

extension TaskHomeViewController: PagingMenuControllerDelegate {
    
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        let didAppearViewController = menuController as! TaskListViewController
        let previousViewController = previousMenuController as! TaskListViewController
        
        didAppearViewController.taskTableView.scrollsToTop = true
        didAppearViewController.getTaskList(didAppearViewController.taskType!, silentMode: true)
        previousViewController.taskTableView.scrollsToTop = false
    }
}
