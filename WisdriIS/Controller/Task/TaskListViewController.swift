//
//  TaskTableViewController.swift
//  WisdriIS
//
//  Created by Allen on 2/25/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import MJRefresh
import SVProgressHUD
import PagingMenuController

class TaskListViewController: BaseViewController {
    
    // MARK: Properties
    var taskType: MaintenanceTaskType?

    var wisTasks = [WISMaintenanceTask]()
    
    // typealias taskInGroup = [WISMaintenanceTask]!
    var wisTasksInGroup = [String : [WISMaintenanceTask]!]()
    var wisTasksInGroupArrangedTitles = [String]()
    
    var currentOperatingCellIndex = -1
    var currentUpdateCellType: TaskListCellUpdatingType = .DoNothing
    var updateCellInfoURLSessionTask: NSURLSessionTask?
    
    // for task type: NotArchived and Archived
    let recordNumberInPage: Int = 20
    var currentPageIndex = 1
    
    var groupType: TaskListGroupType = .None
    
    private let taskListCellID = "TaskListCell"

    private var noRecordsFooterView: InfoView?
    
    private var noRecords = false {
        didSet {
            if noRecords != oldValue {
                taskTableView.tableFooterView = noRecords ? noRecordsFooterView : UIView()
            }
        }
    }
    
    @IBOutlet weak var taskTableView: UITableView!
    
//    private var buttonView = UIView(frame: CGRect(x: 200, y: 350, width: 50, height: 50))
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.updateCellInfoURLSessionTask = nil
        
        // observing notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleNotification(_:)), name: WISNetworkStatusChangedNotification, object: nil)
        
        taskTableView.delegate = self
        taskTableView.dataSource = self

        taskTableView.scrollsToTop = false
        self.automaticallyAdjustsScrollViewInsets = false        
        
        taskTableView.registerNib(UINib(nibName: taskListCellID, bundle: nil), forCellReuseIdentifier: taskListCellID)
//        view.backgroundColor = UIColor.wisBackgroundColor()
        
        taskTableView.separatorColor = UIColor.wisCellSeparatorColor()
        // taskTableView.separatorInset = WISConfig.TaskListCell.separatorInset
        taskTableView.tableFooterView = UIView()
//        taskTableView.addSubview(buttonView)
        
        // for test
        print("Task List View Controller with taskType: " + self.taskType!.rawValue.description + " did load!")
        
        self.taskTableView.mj_header = WISRefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.headerRefresh()
            })
        
        // Add InfoView
        switch self.taskType! {
        case MaintenanceTaskType.ForApproval:
            noRecordsFooterView = InfoView(NSLocalizedString("暂无待审批维保任务"))
        case MaintenanceTaskType.Normal:
            noRecordsFooterView = InfoView(NSLocalizedString("暂无维保任务"))
        case MaintenanceTaskType.NotArchived:
            noRecordsFooterView = InfoView(NSLocalizedString("暂无待归档维保任务"))
        case MaintenanceTaskType.Archived:
            noRecordsFooterView = InfoView(NSLocalizedString("暂无已归档维保任务"))
        default:
            noRecordsFooterView = InfoView(NSLocalizedString("暂无维保任务"))
        }
        
        // move updating op to viewWillAppear() 2016.05.15
        // self.refreshPage()

        if self.taskType == MaintenanceTaskType.NotArchived || self.taskType == MaintenanceTaskType.Archived {
            let footer = WISRefreshFooter(refreshingBlock: {[weak self] () -> Void in
                self?.footerRefresh()
                })
            footer.centerOffset = -4
            footer.pullingPercent = 10.0
            self.taskTableView.mj_footer = footer
        } else {
            self.taskTableView.mj_footer = nil
        }
        
        self.currentPageIndex = 1
        refreshInitalPage()
    }
    
    func refreshInitalPage() {
        self.taskTableView.mj_header.beginRefreshing()
    }
    
    func loadNextPage() {
        self.taskTableView.mj_footer.beginRefreshing()
    }
    
    func headerRefresh() {
        // 如果有上拉“加载更多”正在执行，则取消它
        if self.taskTableView.mj_footer != nil {
            if self.taskTableView.mj_footer.isRefreshing() {
                self.taskTableView.mj_footer.endRefreshing()
            }
        }
        self.currentPageIndex = 1
        getTaskList(taskType!, groupType: self.groupType, silentMode: false)
    }
    
    func footerRefresh() {
        getTaskList(taskType!, groupType: self.groupType, silentMode: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCellInTaskList()
        
        WISUserDefaults.setupSegment()
        
        // for test
        print("Task List View Controller will appear!")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.currentPageIndex = 1
        
        // Control updating task list in taskHomeViewController 2016.05.25
        // getTaskList(taskType!)
    }
    
    func getTaskList(taskType: MaintenanceTaskType, groupType: TaskListGroupType, silentMode: Bool) -> Void {
        switch taskType {
        case .ForApproval, .Normal:
            self.getOnTheGoTaskList(taskType, groupType: groupType, silentMode: silentMode)
        case .NotArchived, .Archived:
            self.getFinshedTaskList(taskType, groupType: groupType, pageIndex: self.currentPageIndex, numberOfRecordsInPage: self.recordNumberInPage, silentMode: silentMode)
        default:
            break
        }
    }
    
    
    private func getOnTheGoTaskList(taskType: MaintenanceTaskType, groupType: TaskListGroupType, silentMode: Bool) -> Void {
        
        if !silentMode {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showWithStatus(NSLocalizedString("Updating maintenance task list", comment: ""))
        }
        WISDataManager.sharedInstance().updateMaintenanceTaskBriefInfoWithTaskTypeID(taskType) { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completedWithNoError {
                let tasks: [WISMaintenanceTask] = updatedData as! [WISMaintenanceTask]
                self.wisTasks.removeAll()
                for task in tasks {
                    self.wisTasks.append(task)
                }
                self.groupTaskList(groupType)
                self.sortTaskList()
                
                self.taskTableView.mj_header.endRefreshing()
                self.updateTableViewInfo()
                
                if !silentMode {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Maintenance task list updated successfully", comment: ""))
                }
                
            } else {
                if self.taskTableView.mj_header.isRefreshing() {
                    self.taskTableView.mj_header.endRefreshing()
                }
                if self.taskTableView.mj_footer != nil {
                    if self.taskTableView.mj_footer.isRefreshing() {
                        self.taskTableView.mj_footer.endRefreshing()
                    }
                }
                self.updateTableViewInfo()
                if !silentMode {
                    WISConfig.errorCode(error)
                }
            }
        }
    }
    
    
    private func getFinshedTaskList(taskType: MaintenanceTaskType, groupType: TaskListGroupType, pageIndex:Int, numberOfRecordsInPage:Int, silentMode: Bool) -> Void {
        if !silentMode {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showWithStatus(NSLocalizedString("Updating maintenance task list", comment: ""))
        }
        WISDataManager.sharedInstance().updateFinishedMaintenanceTaskBriefInfoWithTaskTypeID(taskType, recordNumberInPage: self.recordNumberInPage, pageIndex: self.currentPageIndex) { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completedWithNoError {
                let tasks: [WISMaintenanceTask] = updatedData as! [WISMaintenanceTask]
                
                if pageIndex < 2 {
                    self.wisTasks.removeAll()
                }
                
                for task in tasks {
                    self.wisTasks.append(task)
                }
                self.groupTaskList(groupType)
                self.sortTaskList()
                
                self.currentPageIndex += 1
                
                if self.taskTableView.mj_header.isRefreshing() {
                    self.taskTableView.mj_header.endRefreshing()
                }
                if self.taskTableView.mj_footer != nil {
                    if self.taskTableView.mj_footer.isRefreshing() {
                        self.taskTableView.mj_footer.endRefreshing()
                    }
                }
                self.updateTableViewInfo()
                
                if !silentMode {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Maintenance task list updated successfully", comment: ""))
                }
                
            } else {
                if self.taskTableView.mj_header.isRefreshing() {
                    self.taskTableView.mj_header.endRefreshing()
                }
                if self.taskTableView.mj_footer != nil {
                    if self.taskTableView.mj_footer.isRefreshing() {
                        self.taskTableView.mj_footer.endRefreshing()
                    }
                }
                self.updateTableViewInfo()
                if !silentMode {
                    WISConfig.errorCode(error)
                }
            }
        }
    }
    
    func groupTaskList(groupType: TaskListGroupType) -> Void {
        switch groupType {
        case .None:
            self.wisTasksInGroup.removeAll()
            self.wisTasksInGroupArrangedTitles = [""]
            self.wisTasksInGroup = ["": wisTasks]
            self.wisTasksInGroupArrangedTitles = self.wisTasksInGroup.keys.sort( < )
            
        case .ByProcessSegment:
            self.wisTasksInGroup.removeAll()
            self.wisTasksInGroupArrangedTitles.removeAll()
            
            for task in self.wisTasks {
                if !self.wisTasksInGroupArrangedTitles.contains(task.processSegmentName) {
                    self.wisTasksInGroupArrangedTitles.append(task.processSegmentName)
                }
            }
            if self.wisTasksInGroupArrangedTitles.count > 0 {
                self.wisTasksInGroupArrangedTitles.sortInPlace( < )
            }
            
            for processSegmentName in self.wisTasksInGroupArrangedTitles {
                let filteredTask = self.wisTasks.filter({ $0.processSegmentName == processSegmentName })
                self.wisTasksInGroup[processSegmentName] = filteredTask
            }
            break

            
        case .ByPersonInCharge:
            self.wisTasksInGroup.removeAll()
            self.wisTasksInGroupArrangedTitles.removeAll()
            
            for task in self.wisTasks {
                if !self.wisTasksInGroupArrangedTitles.contains(task.personInCharge.fullName) {
                    self.wisTasksInGroupArrangedTitles.append(task.personInCharge.fullName)
                }
            }
            if self.wisTasksInGroupArrangedTitles.count > 0 {
                self.wisTasksInGroupArrangedTitles.sortInPlace( < )
            }
            
            for fullName in self.wisTasksInGroupArrangedTitles {
                let filteredTask = self.wisTasks.filter({ $0.personInCharge.fullName == fullName })
                self.wisTasksInGroup[fullName] = filteredTask
            }
            break
            
        case .ByTaskState:
            self.wisTasksInGroup.removeAll()
            self.wisTasksInGroupArrangedTitles.removeAll()
            
            for task in self.wisTasks {
                if !self.wisTasksInGroupArrangedTitles.contains(WISConfig.configureStateText(task.state)) {
                    self.wisTasksInGroupArrangedTitles.append(WISConfig.configureStateText(task.state))
                }
            }
            if self.wisTasksInGroupArrangedTitles.count > 0 {
                self.wisTasksInGroupArrangedTitles.sortInPlace( < )
            }
            
            for state in self.wisTasksInGroupArrangedTitles {
                let filteredTask = self.wisTasks.filter({ WISConfig.configureStateText($0.state) == state })
                self.wisTasksInGroup[state] = filteredTask
            }
            break
            
        default:
            break
        }
    }
    
    func sortTaskList() -> Void {
        guard self.wisTasksInGroupArrangedTitles.count > 0 else {
            return
        }
        
        for index in 0...self.wisTasksInGroupArrangedTitles.count - 1 {
            let key = self.wisTasksInGroupArrangedTitles[index]
            var tasksInGroup: [WISMaintenanceTask] = self.wisTasksInGroup[key]!
            tasksInGroup.sortInPlace(WISMaintenanceTask.arrayBackwardWithBOOL())
            self.wisTasksInGroup[key] = tasksInGroup
        }
    }
    
    
    func handleNotification(notification:NSNotification) -> Void {
        
        switch notification.name {
        case WISNetworkStatusChangedNotification:
            // networkingStatusChanges()
            break
            
        case NewTaskSubmittedSuccessfullyNotification:
            getOnTheGoTaskList(taskType!, groupType: self.groupType, silentMode: false)
            // beacause of the mechanism of asynchronous networking accessing , the following code always executs before wisTask being updated.
            // it works imperfect. 2016.05.15
//            dispatch_async(dispatch_get_main_queue()){
//                self.taskTableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: self.wisTasks.count - 1, inSection: 0), atScrollPosition: .Top, animated: true)
//            }
            break
            
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WISNetworkStatusChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NewTaskSubmittedSuccessfullyNotification, object: nil)
        print("Task List View Controller with taskType: " + self.taskType!.rawValue.description + " deinited")
    }
    
    func updateTableViewInfo() {
        self.updateCellInfoURLSessionTask = nil
        self.noRecords = self.wisTasks.isEmpty
        dispatch_async(dispatch_get_main_queue()) {
            self.taskTableView.reloadData()
        }
    }
    
    /// deprecated
    private func updateCellInTaskList() {
        let tableView = self.taskTableView
        let cellUpdatingType = self.currentUpdateCellType
        let cellIndex = self.currentOperatingCellIndex
        
        guard cellIndex > -1 else {
            return
        }
        
        guard cellUpdatingType != .DoNothing else {
            return
        }
        
        switch cellUpdatingType {
        case .ModifyCellInfo:
            let task = self.wisTasks[cellIndex].copy() as! WISMaintenanceTask
            self.updateCellInfoURLSessionTask = WISDataManager.sharedInstance().updateMaintenanceTaskDetailInfoWithTaskID(task.taskID) { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
                if completedWithNoError {
                    let updatedTask = updatedData as! WISMaintenanceTask
                    dispatch_async(dispatch_get_main_queue()){
                        self.taskTableView.beginUpdates()
                        (self.taskTableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: self.currentOperatingCellIndex, inSection: 0)) as! TaskListCell).bind(updatedTask)
                        self.taskTableView.endUpdates()
                        self.updateCellInfoURLSessionTask = nil
                    }
                } else {
                    WISConfig.errorCode(error)
                }
            }
            break
            
        case .AddNewCell:
            getOnTheGoTaskList(taskType!, groupType: self.groupType, silentMode: false)
            break
            
        case .RemoveCell:
            self.wisTasks.removeAtIndex(cellIndex)
            dispatch_async(dispatch_get_main_queue()) {
                tableView.setEditing(true, animated: true)
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow: cellIndex, inSection: 0)], withRowAnimation: .Fade)
                tableView.endUpdates()
                tableView.setEditing(false, animated: true)
            }
            break
            
        case .DoNothing: break
        }
    
        self.currentOperatingCellIndex = -1
        self.currentUpdateCellType = .DoNothing
    }
    
    @objc private func networkingStatusChanges() -> Void {
        guard self.updateCellInfoURLSessionTask != nil else {
            return
        }
        
        if (WISDataManager.sharedInstance().networkReachabilityStatus != .NotReachable && WISDataManager.sharedInstance().networkReachabilityStatus != .Unknown) {
            self.updateCellInfoURLSessionTask!.resume()
            
        } else {
            self.updateCellInfoURLSessionTask!.suspend()
        }
    }
}

    // MARK: - Table view data source

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.wisTasksInGroupArrangedTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard wisTasksInGroup.count > 0 else {
            return 0
        }
        
        return self.wisTasksInGroup[self.wisTasksInGroupArrangedTitles[section]]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard wisTasksInGroup.count > 0 else {
            return nil
        }
        
        if self.wisTasksInGroupArrangedTitles[section] == "" {
            return nil
        } else {
            return self.wisTasksInGroupArrangedTitles[section]
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if wisTasksInGroupArrangedTitles.count == 1 && wisTasksInGroupArrangedTitles[0] == "" {
            return CGFloat.min
        } else {
            return 50
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.section < self.wisTasksInGroupArrangedTitles.count else {
            return UITableViewCell()
        }
        
        let tasksInGroup = self.wisTasksInGroup[self.wisTasksInGroupArrangedTitles[indexPath.section]]!
        guard indexPath.row < tasksInGroup.count else {
            return getCell(tableView, cell: TaskListCell.self, indexPath: NSIndexPath(forRow: tasksInGroup.count - 1, inSection: indexPath.section))
        }
        
        let cell = getCell(tableView, cell: TaskListCell.self, indexPath: indexPath)
        print("index of Cell: \(indexPath.row)")
        cell.bind(tasksInGroup[indexPath.row])
        return cell
    }
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        // headerView.textLabel?.font = UIFont.italicSystemFontOfSize(15)
        headerView.textLabel?.textColor = UIColor.grayColor()
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let wisTask = self.wisTasks[indexPath.row]
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        performSegueWithIdentifier("showTaskDetail", sender: indexPath.row)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTaskDetail" {
            let vc = segue.destinationViewController as! TaskDetailViewController
            vc.indexInList = sender as! Int
            self.currentOperatingCellIndex = vc.indexInList
            self.currentUpdateCellType = .DoNothing
            vc.wisTask = self.wisTasks[vc.indexInList] as WISMaintenanceTask
            vc.superViewController = self
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.sourceViewController as? NewTaskViewController, task = sourceViewController.task {
//            let newIndexPath = NSIndexPath(forRow: tasks.count, inSection: 0)
//            tasks.append(task)
//            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
//        }
//    }
}


enum TaskListCellUpdatingType: String {
    case DoNothing = "Do Nothing"
    case ModifyCellInfo = "Modify Cell Info"
    case AddNewCell = "Add New Cell"
    case RemoveCell = "Remove Cell"
}
