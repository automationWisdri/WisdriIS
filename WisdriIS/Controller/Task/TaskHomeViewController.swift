//
//  TaskHomeViewController.swift
//  WisdriIS
//
//  Created by Allen on 16/4/20.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import PagingMenuController
import LMDropdownView
import SVProgressHUD

class TaskHomeViewController: BaseViewController {
    
    var viewControllers = [TaskListViewController]()
    var originalTitle = NSLocalizedString("Task List", comment: "")
    
    // for show new task uploading title
    let newTaskUploadingTitleHeader = NSLocalizedString("New Task Uploading...", comment: "")
    
    var taskListGroupType: TaskListGroupType = .None {
        didSet {
            if taskListGroupType != oldValue {
                // uploading list
            }
        }
    }
    
    // for drop down filter view
    var filterDropDownView: LMDropdownView = LMDropdownView()
    var filterContentView: TaskListFilterContentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n====================\nTaskHomeViewController did load\n====================\n")
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = originalTitle
        
        let tempNavigationBackButton = UIBarButtonItem()
        tempNavigationBackButton.title = self.originalTitle
        self.navigationItem.backBarButtonItem = tempNavigationBackButton
        
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
        
        //
        // LOADING TASK LIST IN PAGE VIEW *****
        //
        let storyboard = UIStoryboard(name: "TaskList", bundle: nil)
        
        let taskListForApproval = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        let taskListNormal = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        let taskListArchived = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        let taskListNotArchived = storyboard.instantiateViewControllerWithIdentifier("TaskListViewController") as! TaskListViewController
        
        taskListForApproval.taskType = MaintenanceTaskType.ForApproval
        taskListForApproval.groupType = .None
        taskListForApproval.title = "待审批"

        taskListNormal.taskType = MaintenanceTaskType.Normal
        taskListNormal.groupType = .None
        taskListNormal.title = "处理中"
        
        taskListArchived.taskType = MaintenanceTaskType.Archived
        taskListArchived.groupType = .None
        taskListArchived.title = "已归档"
        
        taskListNotArchived.taskType = MaintenanceTaskType.NotArchived
        taskListNotArchived.groupType = .None
        taskListNotArchived.title = "待归档"
        
//        var viewControllers = [TaskListViewController]()
        
        // for test
        #if DEBUG
            print("RoleCodes: " + WISDataManager.sharedInstance().roleCodes.description)
            print(WISDataManager.sharedInstance().currentUser.roleCode)
            print(currentUser.roleCode)
        #endif

        // 在实现筛选功能前, 暂时叫 "分组"
        let leftBarItem = UIBarButtonItem.init(title: NSLocalizedString("Group", comment: ""), style: .Plain, target: self, action: #selector(self.popTaskListFilterPanel(_:)))
        self.navigationItem.leftBarButtonItem = leftBarItem
        
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
        
        //
        // FILTER VIEW *****
        //
        self.filterContentView = TaskListFilterContentView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), min(CGRectGetHeight(self.view.bounds) - 50, 450)), parentViewController: self, initialGroupSelection: TaskListGroupType.None)
        
        self.filterDropDownView.delegate = self
        
        // Customize Dropdown style
        self.filterDropDownView.closedScale = 1.0
        self.filterDropDownView.blurRadius = 3;
        self.filterDropDownView.blackMaskAlpha = 0.2;
        self.filterDropDownView.animationDuration = 0.5;
        self.filterDropDownView.animationBounceHeight = 0.0;
        
        self.filterDropDownView.contentBackgroundColor = UIColor.whiteColor()
        
        self.filterDropDownView.delegate = self
        self.filterContentView?.delegate = self
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
        currentViewController.getTaskList(currentViewController.taskType!, groupType: currentViewController.groupType, silentMode: true)
        
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
            currentViewController.getTaskList(currentViewController.taskType!, groupType: currentViewController.groupType, silentMode: true)
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
                    self.navigationItem.title = self.newTaskUploadingTitleHeader
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
                
                self.navigationItem.title = self.newTaskUploadingTitleHeader + "(\(totalUploadingPercentage)%)"
                
            case UploadingState.UploadingCompleted.rawValue:
                
                let pagingMenuController = self.childViewControllers.first as! PagingMenuController
                let currentViewController = pagingMenuController.currentViewController as! TaskListViewController
                currentViewController.getTaskList(currentViewController.taskType!, groupType: currentViewController.groupType, silentMode: true)
                
                if uploadingTaskDictionary.count == 0 {
                    self.navigationItem.title = self.originalTitle
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
        didAppearViewController.getTaskList(didAppearViewController.taskType!, groupType: didAppearViewController.groupType, silentMode: true)
        previousViewController.taskTableView.scrollsToTop = false
    }
}


    // MARK: - extension - Drop down control

extension TaskHomeViewController {
    
    func popTaskListFilterPanel(sender: UIBarButtonItem) -> Void {
        showDropDownViewFromDirection(.Top)
    }
    
    func showDropDownViewFromDirection(direction: LMDropdownViewDirection) -> Void {
            self.filterDropDownView.direction = direction;
        
        if self.filterDropDownView.isOpen {
            self.filterDropDownView.hide()
        
        } else {
            switch direction {
            case .Top:
                self.filterDropDownView.showFromNavigationController(self.navigationController, withContentView: self.filterContentView)
                break
                
            default:
                break
            }
        }
    }
}


extension TaskHomeViewController: LMDropdownViewDelegate {
    func dropdownViewWillShow(dropdownView: LMDropdownView!) {
        self.filterContentView?.prepareView()
    }
}


    // MARK: - extension - Drop down data delivery

extension TaskHomeViewController: TaskListFilterContentViewDelegate {
    
    func taskListFilterContentViewConfirmed(groupType: TaskListGroupType) {
        print("OK Button pressed")
        print("Selected group type is " + groupType.stringOfType)
        if self.filterDropDownView.isOpen {
            self.filterDropDownView.hide()
        }
        
        for viewController in self.viewControllers {
            viewController.groupType = groupType
        }
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        let currentViewController = pagingMenuController.currentViewController as! TaskListViewController
        
        currentViewController.groupTaskList(groupType)
        currentViewController.sortTaskList()
        currentViewController.updateTableViewInfo()
        
    }
    
    func taskListFilterContentViewCancelled() {
        print("Cancel Button pressed")
        if self.filterDropDownView.isOpen {
            self.filterDropDownView.hide()
            
        }
    }
}


enum TaskListGroupType: Int {
    case None = 0
    case ByProcessSegment = 1
    case ByPersonInCharge = 2
    case ByTaskState = 3
    
    static let count: Int = {
        return 4
    }()
    
    var stringOfType: String {
        switch self {
        case .None:
            return NSLocalizedString("None", comment: "")
        case .ByProcessSegment:
            return NSLocalizedString("By process segment", comment: "")
        case .ByPersonInCharge:
            return NSLocalizedString("By person in charge", comment: "")
        case .ByTaskState:
            return NSLocalizedString("By task state", comment: "")
        }
    }
}
