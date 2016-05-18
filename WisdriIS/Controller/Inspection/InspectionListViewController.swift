//
//  InspectionListViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/10/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

enum InspectionTaskType {
    /// 当前点检任务
    case OnTheGo
    /// 历史点检任务
    case Historical
    /// 逾期点检任务
    case OverDue
}

class InspectionListViewController : BaseViewController {
    
    // var inspectionTasks = [WISInspectionTask]()
    
    @IBOutlet weak var inspectionTableView: UITableView!
    
    private let inspectionListCellID = "InspectionListCell"
    private let inspectionDetailViewSegueID = "showInspectionDetail"
    
    var inspectionTaskType: InspectionTaskType = .Historical
    
    var showMoreInformation = false
    var inspectionOperationEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.inspectionSearchBar.delegate = self
        
        inspectionTableView.delegate = self
        inspectionTableView.dataSource = self
        
        // title = NSLocalizedString("Inpection Task List")
        
        /// *** list setting
        inspectionTableView.registerNib(UINib(nibName: inspectionListCellID, bundle: nil), forCellReuseIdentifier: inspectionListCellID)
        
        inspectionTableView.separatorColor = UIColor.yepCellSeparatorColor()
        inspectionTableView.separatorInset = YepConfig.ContactsCell.separatorInset
        inspectionTableView.tableFooterView = UIView()
        
        inspectionTableView.mj_header = WISRefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
            })
        self.refreshPage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        inspectionTableView.reloadData()
        // self.inspectionTableView.contentOffset = CGPointMake(0.0, self.inspectionSearchBar.bounds.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshPage(){
        inspectionTableView.mj_header.beginRefreshing()
    }
    
    
    func refresh(){
        if WISDataManager.sharedInstance().networkReachabilityStatus != .NotReachable {
            loadDeviceTypes()
            loadInspectionTaskList()
        } else {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showErrorWithStatus(NSLocalizedString("Networking Not Reachable"))
        }
    
        inspectionTableView.mj_header.endRefreshing()
    }
    
    
    //
    
    
    
//    func performSegueToInspectionDetailView(inspectionTask:WISInspectionTask, needToScanCode:Bool, enableOperation:Bool) -> Void {
//        let board = UIStoryboard.init(name: "InspectionDetail", bundle: NSBundle.mainBundle())
//        let viewController = board.instantiateViewControllerWithIdentifier("InspectionDetailViewController") as! InspectionDetailViewController
//        viewController.inspectionTask = inspectionTask
//        viewController.isQRCodeMatched = !needToScanCode
//        // 需要根据角色来区分是否详细任务信息是否可编辑
//        viewController.operationEnabled = enableOperation
//        
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
    
    func loadDeviceTypes() {
        WISDataManager.sharedInstance().updateDeviceTypesInfoWithCompletionHandler { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) in
            if completedWithNoError {
                let deviceTypes: [WISDeviceType]?
                deviceTypes = (updatedData as! [WISDeviceType])
                
                if deviceTypes!.count > 0 {
                    for deviceType in deviceTypes! {
                        WISInsepctionDataManager.sharedInstance().deviceTypes[deviceType.deviceTypeID] = deviceType
                    }
                }
                
            } else {
                switch error.code {
                case WISErrorCode.ErrorCodeResponsedNULLData.rawValue:
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("Networking state abnormal, please try again later!", comment: ""))
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    func loadInspectionTaskList() {
        switch self.inspectionTaskType {
        case .OnTheGo: loadOnTheGoInspectionTaskList()
        case .Historical: loadHistoricalInspectionTaskList()
        case .OverDue: loadOverDueInspectionTaskList()
        }
    }
    
    
    func loadOnTheGoInspectionTaskList() {
        SVProgressHUD.setDefaultMaskType(.None)
        SVProgressHUD.showWithStatus(NSLocalizedString("Updating on the go inspection task list", comment: ""))
        
        WISDataManager.sharedInstance().updateInspectionsInfoWithCompletionHandler { (completionWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completionWithNoError {
                let inspectionTasks: [WISInspectionTask] = updatedData as! [WISInspectionTask]
                WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks.removeAll()
                if inspectionTasks.count > 0 {
                    for inspectionTask in inspectionTasks {
                        let task = inspectionTask.copy() as! WISInspectionTask
                        let deviceID = task.device.deviceID
                        guard !WISInsepctionDataManager.sharedInstance().uploadingQueueContainsInspectionTaskByDeviceID(deviceID) else {
                            continue
                        }
                        if WISInsepctionDataManager.sharedInstance().deviceTypes[task.device.deviceType.deviceTypeID] != nil {
                            task.device.deviceType = WISInsepctionDataManager.sharedInstance().deviceTypes[task.device.deviceType.deviceTypeID]?.copy() as! WISDeviceType
                        }
                        WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks.append(task)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.inspectionTableView.reloadData()
                }
                
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus(NSLocalizedString("On the go inspection task list updated successfully", comment: ""))
                
            } else {
                switch error.code {
                case WISErrorCode.ErrorCodeResponsedNULLData.rawValue:
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("Networking state abnormal, please try again later!", comment: ""))
                    break
                    
                default:
                    errorCode(error)
                    break
                }
            }
        }
    }
    
    func loadHistoricalInspectionTaskList() {
        // SVProgressHUD.setDefaultMaskType(.None)
        // SVProgressHUD.showWithStatus(NSLocalizedString("Updating historical inspection task list", comment: ""))
    }
    
    func loadOverDueInspectionTaskList() {
        SVProgressHUD.setDefaultMaskType(.None)
        SVProgressHUD.showWithStatus(NSLocalizedString("Updating over due inspection task list", comment: ""))
        
        WISDataManager.sharedInstance().updateOverDueInspectionsInfoWithCompletionHandler { (completionWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completionWithNoError {
                let inspectionTasks: [WISInspectionTask] = updatedData as! [WISInspectionTask]
                WISInsepctionDataManager.sharedInstance().overDueInspectionTasks.removeAll()
                if inspectionTasks.count > 0 {
                    for inspectionTask in inspectionTasks {
                        let task = inspectionTask.copy() as! WISInspectionTask
                        
                        if WISInsepctionDataManager.sharedInstance().deviceTypes[task.device.deviceType.deviceTypeID] != nil {
                            task.device.deviceType = WISInsepctionDataManager.sharedInstance().deviceTypes[task.device.deviceType.deviceTypeID]?.copy() as! WISDeviceType
                        }
                        WISInsepctionDataManager.sharedInstance().overDueInspectionTasks.append(task)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.inspectionTableView.reloadData()
                }
                
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Over due inspection task list updated successfully", comment: ""))
                
            } else {
                switch error.code {
                case WISErrorCode.ErrorCodeResponsedNULLData.rawValue:
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("Networking state abnormal, please try again later!", comment: ""))
                    break
                    
                default:
                    errorCode(error)
                    break
                }
            }
        }
    }
}


// MARK: - Table view data source & delegate method

extension InspectionListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.inspectionTaskType {
        case .OnTheGo: return WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks.count
        case .Historical: return WISInsepctionDataManager.sharedInstance().historicalInspectionTasks.count
        case .OverDue: return WISInsepctionDataManager.sharedInstance().overDueInspectionTasks.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let inspectionTasks: [WISInspectionTask]
        
        switch self.inspectionTaskType {
        case .OnTheGo: inspectionTasks = WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks
        case .Historical: inspectionTasks = WISInsepctionDataManager.sharedInstance().historicalInspectionTasks
        case .OverDue: inspectionTasks = WISInsepctionDataManager.sharedInstance().overDueInspectionTasks
        }
        
        guard indexPath.row < inspectionTasks.count else {
            return getCell(tableView, cell: InspectionListCell.self, indexPath: NSIndexPath(forRow: inspectionTasks.count - 1, inSection: 0))
        }
        
        let cell = getCell(tableView, cell: InspectionListCell.self, indexPath: indexPath)
        cell.bindData(inspectionTasks[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let task: WISInspectionTask
        
        switch self.inspectionTaskType {
        case .OnTheGo: task = WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks[indexPath.row]
        case .Historical: task = WISInsepctionDataManager.sharedInstance().historicalInspectionTasks[indexPath.row]
        case .OverDue: task = WISInsepctionDataManager.sharedInstance().overDueInspectionTasks[indexPath.row]
        }
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // performSegueWithIdentifier(inspectionDetailViewSegueID, sender: equipment)
        InspectionDetailViewController.performPushToInspectionDetailView(self, inspectionTask: task, index:indexPath.row,showMoreInformation: self.showMoreInformation, enableOperation: inspectionOperationEnabled)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == inspectionDetailViewSegueID {
            let viewController = segue.destinationViewController as! InspectionDetailViewController
            viewController.inspectionTask = sender as? WISInspectionTask
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


