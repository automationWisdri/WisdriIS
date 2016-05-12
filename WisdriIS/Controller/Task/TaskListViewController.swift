//
//  TaskTableViewController.swift
//  WisdriIS
//
//  Created by Allen on 2/25/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import MJRefresh
import PagingMenuController

class TaskListViewController: BaseViewController {
    
    // MARK: Properties
    var taskType: MaintenanceTaskType?

    var wisTasks = [WISMaintenanceTask]()
    
    private let taskListCellID = "TaskListCell"

//    var tab: String? = nil
//    private var _tableView: UITableView!
    
    @IBOutlet weak var taskTableView: UITableView!
    
//    private var buttonView = UIView(frame: CGRect(x: 200, y: 350, width: 50, height: 50))
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        taskTableView.delegate = self
        taskTableView.dataSource = self

        self.automaticallyAdjustsScrollViewInsets = false        
        
        taskTableView.registerNib(UINib(nibName: taskListCellID, bundle: nil), forCellReuseIdentifier: taskListCellID)
//        view.backgroundColor = UIColor.yepBackgroundColor()
        
        taskTableView.separatorColor = UIColor.yepCellSeparatorColor()
        taskTableView.separatorInset = YepConfig.ContactsCell.separatorInset
        taskTableView.tableFooterView = UIView()
//        taskTableView.addSubview(buttonView)
        
        
        
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
                self.taskTableView.reloadData()

            } else {
                
                errorCode(error)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        performSegueWithIdentifier("showTaskDetail", sender: wisTask)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTaskDetail" {
            let vc = segue.destinationViewController as! TaskDetailViewController
            vc.wisTask = sender as? WISMaintenanceTask
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
