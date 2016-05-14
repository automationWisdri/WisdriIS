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
    var currentOperatingCellIndex = -1
    var currentUpdateCellType:TaskListCellUpdatingType = .DoNothing
    var updateCellInfoURLSessionTask:NSURLSessionTask?
    
    private let taskListCellID = "TaskListCell"

//    var tab: String? = nil
//    private var _tableView: UITableView!
    
    @IBOutlet weak var taskTableView: UITableView!
    
//    private var buttonView = UIView(frame: CGRect(x: 200, y: 350, width: 50, height: 50))
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.updateCellInfoURLSessionTask = nil
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.networkingStatusChanges(_:)), name: WISNetworkStatusChangedNotification, object: nil)
        
        taskTableView.delegate = self
        taskTableView.dataSource = self

        self.automaticallyAdjustsScrollViewInsets = false        
        
        taskTableView.registerNib(UINib(nibName: taskListCellID, bundle: nil), forCellReuseIdentifier: taskListCellID)
//        view.backgroundColor = UIColor.yepBackgroundColor()
        
        taskTableView.separatorColor = UIColor.yepCellSeparatorColor()
        taskTableView.separatorInset = YepConfig.ContactsCell.separatorInset
        taskTableView.tableFooterView = UIView()
//        taskTableView.addSubview(buttonView)
        
        // for test
        print("Task List View Controller did load!")
        
        self.taskTableView.mj_header = WISRefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
            })
        self.refreshPage()
        
//        
//        let footer = WISRefreshFooter(refreshingBlock: {[weak self] () -> Void in
//            self?.getNextPage()
//            })
//        footer.centerOffset = -4
//        self.tableView.mj_footer = footer
//
//        self.view.addSubview(self.taskTableView)
//        self.taskTableView.snp_makeConstraints{ (make) -> Void in
//            make.top.right.bottom.left.equalTo(self.view)
//        }
    }
    
    func refreshPage(){
        self.taskTableView.mj_header.beginRefreshing();
//        WISSettings.sharedInstance[kHomeTab] = tab
    }
    
    func refresh(){
        
        //如果有上拉加载更多 正在执行，则取消它
//        if self.taskTableView.mj_footer.isRefreshing() {
//            self.taskTableView.mj_footer.endRefreshing()
//        }
        
        getTaskList(taskType!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCellInTaskList()
        
        // for test
        print("Task List View Controller will appear!")
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.refreshPage()
    }
    
    func getTaskList(taskType: MaintenanceTaskType) {
        WISDataManager.sharedInstance().updateMaintenanceTaskBriefInfoWithTaskTypeID(taskType) { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completedWithNoError {
                let tasks: Array<WISMaintenanceTask> = updatedData as! Array<WISMaintenanceTask>
                self.wisTasks.removeAll()

                for task in tasks {
                    self.wisTasks.append(task)
                }
                
                self.taskTableView.mj_header.endRefreshing()
                self.updateTableViewInfo()
                
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus("任务列表更新成功!")

            } else {
                errorCode(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WISNetworkStatusChangedNotification, object: nil)
    }
    
    private func updateTableViewInfo() {
        self.updateCellInfoURLSessionTask = nil
        dispatch_async(dispatch_get_main_queue()){
            self.taskTableView.reloadData()
        }
    }
    
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
                    errorCode(error)
                }
            }
            break
            
        case .AddNewCell:
            getTaskList(taskType!)
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
    
    
    @objc private func networkingStatusChanges(networkNotification: NSNotification) -> Void {
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wisTasks.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return tableView.wis_heightForCellWithIdentifier(TaskTableViewCell.self, indexPath: indexPath) { (cell) -> Void in
//            cell.bind(self.wisTasks[indexPath.row])
//        }
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: TaskListCell.self, indexPath: indexPath)
        cell.bind(self.wisTasks[indexPath.row])
        return cell
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
