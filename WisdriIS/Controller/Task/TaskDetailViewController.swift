//
//  TaskDetailViewController.swift
//  WisdriIS
//
//  Created by Allen on 2/26/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

class TaskDetailViewController: BaseViewController {
    
    // MARK: Properties
    @IBOutlet weak var taskDetailTableView: UITableView!

    private let taskDetailSingleInfoCellID = "TaskDetailSingleInfoCell"
    private let taskDetailDoubleInfoCellID = "TaskDetailDoubleInfoCell"
    private let taskDetailLargeInfoCellID = "TaskDetailLargeInfoCell"
    private let taskDescriptionCellID = "TaskDescriptionCell"
    private let taskPlanCellID = "TaskPlanCell"
    private let taskStateCellID = "TaskStateCell"
    private let taskRateCellID = "TaskRateCell"
    
    private var currentUser: WISUser?
    var wisTask: WISMaintenanceTask?
    var indexInList = 0
    var superViewController: UIViewController?
    
    var imagesInfo = [String : WISFileInfo]()
    var imagesArray = [UIImage]()
    var taskImagesFileInfoArray = [WISFileInfo]()
    var planImagesFileInfoArray = [WISFileInfo]()
    private var planCount = 0
    private var stateCount = 0
    private var getTaskDetailToken = false
    
    private let pickUserSegueIdentifier = "pickUserForPassOperation"
    private let assignUserSegueIdentifier = "assignUserForPassOperation"
    private let submitQuickPlanSegueIdentifier = "submitQuickPlanOperation"
    private let submitPlanSegueIdentifier = "submitPlanOperation"
    private let modifyPlanSegueIdentifier = "modifyPlanOperation"
    private let approveSegueIdentifier = "approveOperation"
    private let recheckSegueIdentifier = "recheckOperation"
    private let startDisputeSegueIdentifier = "startDisputeOperation"
    private let remarkSegueIdentifier = "remarkOperation"
    private let continueSegueIdentifier = "continueOperation"
    
    private lazy var operationTypesView: OperationTypesView = {
        let view = OperationTypesView()
        
        // 技术主管归档
        view.archiveOperation = { [weak self] in
            self?.performSegueWithIdentifier("archiveTask", sender: nil)
        }
        
        // 前方部长转单
        view.assignOperation = { [weak self] in
            self?.performSegueWithIdentifier("assignUser", sender: nil)
        }
        
        // 前方部长备注
        view.remarkOperation = { [weak self] in
            self?.performSegueWithIdentifier("remarkTask", sender: nil)
        }
        
        // 生产人员评价
        view.confirmOperation = { [weak self] in
            self?.performSegueWithIdentifier("ratingTask", sender: nil)
        }
        
        // 技术主管提交厂级负责人审核
        view.recheckOperation = { [weak self] in
            self?.performSegueWithIdentifier("recheckOperation", sender: nil)
        }

        // 厂级负责人不同意方案、技术主管不同意生产人员的拒绝确认请求
        view.rejectOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            
            let imagesInfo = (currentTask?.maintenancePlans.lastObject as! WISMaintenancePlan).imagesInfo
            var taskImageInfo = [String : WISFileInfo]()
            for item: AnyObject in imagesInfo.allKeys {
                taskImageInfo[item as! String] = (imagesInfo.objectForKey(item) as! WISFileInfo)
            }
            
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Reject, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: taskImageInfo, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(WISConfig.HUDString.success)
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
        }
        
        // 工程师完成任务
        view.completeOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.TaskComplete, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(WISConfig.HUDString.success)
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
        }
        
        // 工程师转单
        view.passOperation = { [weak self] in
            self?.performSegueWithIdentifier("pickUser", sender: nil)
        }
        
        // 工程师接受转单
        view.acceptPassOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.AcceptPassOnTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Accept Success"))
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                
                }
            })
        }
        
        // 工程师拒绝接受转单
        view.refusePassOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.RefuseToReceiveTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Refuse pass request"))
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                    
                }
            })
        }
        
        // 工程师接受指派转单
        view.acceptAssignedOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.AcceptAssignedPassOnTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Accept Success"))
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                    
                }
            })
        }
        
        // 审批同意维保方案
        view.approveOperation = { [weak self] in
            // 厂级负责人审批同意维保方案
            if WISDataManager.sharedInstance().currentUser.roleCode == WISDataManager.sharedInstance().roleCodes[RoleCode.FactoryManager.rawValue]  {
                SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
                
                let imagesInfo = (currentTask?.maintenancePlans.lastObject as! WISMaintenancePlan).imagesInfo
                var taskImageInfo = [String : WISFileInfo]()
                for item: AnyObject in imagesInfo.allKeys {
                    taskImageInfo[item as! String] = (imagesInfo.objectForKey(item) as! WISFileInfo)
                }
                
                WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Approve, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: taskImageInfo, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                    
                    if completedWithNoError {
                        SVProgressHUD.setDefaultMaskType(.None)
                        SVProgressHUD.showSuccessWithStatus(WISConfig.HUDString.success)
                        self?.navigationController?.popViewControllerAnimated(true)
                    
                    } else {
                    
                        WISConfig.errorCode(error)
                    }
                })
                
            } else {
                // 技术主管审批同意维保方案
                self?.performSegueWithIdentifier("approveOperation", sender: nil)
            }
        }
        
        // 工程师提交维保方案
        view.submitPlanOperation = { [weak self] in
            self?.performSegueWithIdentifier("submitPlanOperation", sender: nil)
        }
        
        // 工程师提交快速维保方案
        view.submitQuickPlanOperation = { [weak self] in
            self?.performSegueWithIdentifier("submitQuickPlanOperation", sender: nil)
        }
        
        // 工程师修改维保方案
        view.modifyPlanOperation = { [weak self] in
            self?.performSegueWithIdentifier("modifyPlanOperation", sender: nil)
        }
        
        // 工程师接单
        view.acceptOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.AcceptMaintenanceTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Accpet Success"))
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
        }
        
        // 生产人员撤单
        view.repealOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Cancel, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Repeal Success"))
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
        }
        
        // 生产人员拒绝确认
        view.declineOperation = { [weak self] in
            SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: nil, operationType: MaintenanceTaskOperationType.DeclineToConfirm, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Refuse task completion"))
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
        }
        
        // 技术主管发起争议流程
        view.startDisputeOperation = { [weak self] in
            self?.performSegueWithIdentifier("startDisputeOperation", sender: nil)
        }
        
        // 技术主管审批继续维保
        view.continueOperation = { [weak self] in
            self?.performSegueWithIdentifier("continueOperation", sender: nil)
        }
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request Data
        getTaskDetail(silentMode: false)
        getTaskDetailToken = true
        
        // MakeUI
        title = NSLocalizedString("Task Detail", comment: "")
        
        currentUser = WISDataManager.sharedInstance().currentUser
        self.view.backgroundColor = UIColor.wisBackgroundColor()
        
        taskDetailTableView.delegate = self
        taskDetailTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handlePlanUploadingNotification(_:)), name: MaintenancePlanUploadingNotification, object: nil)
        
        taskDetailTableView.registerNib(UINib(nibName: taskDetailSingleInfoCellID, bundle: nil), forCellReuseIdentifier: taskDetailSingleInfoCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskDetailDoubleInfoCellID, bundle: nil), forCellReuseIdentifier: taskDetailDoubleInfoCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskDetailLargeInfoCellID, bundle: nil), forCellReuseIdentifier: taskDetailLargeInfoCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskDescriptionCellID, bundle: nil), forCellReuseIdentifier: taskDescriptionCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskPlanCellID, bundle: nil), forCellReuseIdentifier: taskPlanCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskStateCellID, bundle: nil), forCellReuseIdentifier: taskStateCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskRateCellID, bundle: nil), forCellReuseIdentifier: taskRateCellID)
        
        taskDetailTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !getTaskDetailToken {
            getTaskDetail(silentMode: true)
        }
        getTaskDetailToken = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTaskDetail(silentMode silentMode: Bool) {
        // 获取任务详情
        if !silentMode {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.show()
        }
        WISDataManager.sharedInstance().updateMaintenanceTaskDetailInfoWithTaskID(wisTask?.taskID) { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completedWithNoError {
                self.wisTask = updatedData as? WISMaintenanceTask
                currentTask = self.wisTask
                WISUserDefaults.getCurrentTaskOperations()
                
                if let progress = uploadingPlanDictionary[self.wisTask!.taskID] {
                    let uploadingPercentage = Int(progress.fractionCompleted * 100)
                    self.navigationItem.title = "方案上传...(\(uploadingPercentage)%)"
                    self.navigationItem.rightBarButtonItem?.enabled = false
                } else {
                    self.navigationItem.title = NSLocalizedString("Task Detail", comment: "")
                    if currentTaskOperations.first?.operationName != NSLocalizedString("NULL Operation") {
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    } else {
                        self.navigationItem.rightBarButtonItem?.enabled = false
                    }
                }

                // 获取任务图片
//                self.taskImagesFileInfoArray.removeAll()
//                
//                for item : AnyObject in self.wisTask!.imagesInfo.allKeys {
////                    self.imagesInfo[item as! String] = self.wisTask!.imagesInfo.objectForKey(item) as? WISFileInfo
//                    self.taskImagesFileInfoArray.append(self.wisTask!.imagesInfo.objectForKey(item) as! WISFileInfo)
//                }
                
                // 获取方案的数量和状态数量
                if self.wisTask!.maintenancePlans != nil {
                    self.planCount = self.wisTask!.maintenancePlans.count
                    self.stateCount = self.wisTask!.passedStates.count
                }
                if !silentMode {
                    SVProgressHUD.dismiss()
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.taskDetailTableView.reloadData()
                }
                
            } else {
                WISConfig.errorCode(error)
            }
        }
    }
    
    @IBAction func createNewOperation(sender: AnyObject) {
        if let window = view.window {
            operationTypesView.showInView(window)
        }
    }
    
    @objc func handlePlanUploadingNotification(notification: NSNotification) {
        guard let state = notification.object else {
            return
        }

        dispatch_async(dispatch_get_main_queue()) {
            switch state as! String {
            case UploadingState.UploadingStart.rawValue:
                if let _ = uploadingPlanDictionary[self.wisTask!.taskID] {
                    self.navigationItem.title = "方案上传..."
                    self.navigationItem.rightBarButtonItem?.enabled = false
                }
            case UploadingState.UploadingPending.rawValue:
                if let progress = uploadingPlanDictionary[self.wisTask!.taskID] {
                    if progress.fractionCompleted > 0 {
                        let uploadingPercentage = Int(progress.fractionCompleted * 100)
                        self.navigationItem.title = "方案上传...(\(uploadingPercentage)%)"
                    }
                    self.navigationItem.rightBarButtonItem?.enabled = false
                }
            case UploadingState.UploadingCompleted.rawValue:
                guard let _ = uploadingPlanDictionary[self.wisTask!.taskID] else {
                    self.navigationItem.title = NSLocalizedString("Task Detail", comment: "")
                    self.getTaskDetail(silentMode: true)
                    return
                }
            default:
                return
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MaintenancePlanUploadingNotification, object: nil)
        print("Notification \(MaintenancePlanUploadingNotification) deregistered in \(self) while deiniting")
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "pickUser":
            let vc = segue.destinationViewController as! PickUserViewController
            vc.segueIdentifier = self.pickUserSegueIdentifier
            break
            
        case "assignUser":
            let vc = segue.destinationViewController as! PickUserViewController
            vc.segueIdentifier = self.assignUserSegueIdentifier
            break
            
        case "submitQuickPlanOperation":
            let vc = segue.destinationViewController as! SubmitPlanViewController
            vc.segueIdentifier = self.submitQuickPlanSegueIdentifier
            break
            
        case "submitPlanOperation":
            let vc = segue.destinationViewController as! SubmitPlanViewController
            vc.segueIdentifier = self.submitPlanSegueIdentifier
            break
            
        case "modifyPlanOperation":
            let vc = segue.destinationViewController as! SubmitPlanViewController
            vc.segueIdentifier = self.modifyPlanSegueIdentifier
            vc.wisPlan = wisTask!.maintenancePlans.lastObject as? WISMaintenancePlan
            break
            
        case "approveOperation":
            let vc = segue.destinationViewController as! ModifyPlanViewController
            vc.segueIdentifier = self.approveSegueIdentifier
            vc.wisPlan = wisTask!.maintenancePlans.lastObject as? WISMaintenancePlan
            break
            
        case "recheckOperation":
            let vc = segue.destinationViewController as! ModifyPlanViewController
            vc.segueIdentifier = self.recheckSegueIdentifier
            vc.wisPlan = wisTask!.maintenancePlans.lastObject as? WISMaintenancePlan
            break
            
        case "startDisputeOperation":
            let vc = segue.destinationViewController as! RemarkViewController
            vc.segueIdentifier = self.startDisputeSegueIdentifier
            break
            
        case "remarkTask":
            let vc = segue.destinationViewController as! RemarkViewController
            vc.segueIdentifier = self.remarkSegueIdentifier
            break
            
        case "continueOperation":
            let vc = segue.destinationViewController as! ModifyPlanViewController
            vc.segueIdentifier = self.continueSegueIdentifier
            vc.wisPlan = wisTask!.maintenancePlans.lastObject as? WISMaintenancePlan
            break
            
        default:
            break
        }
        
        
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TaskDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    private enum Section: Int {
        case TaskBasicInfo
        case TaskDescription
        case TaskHandleInfo
        case TaskState
        case Remark
        case Rating
    }
    
    private enum BasicInfoRow: Int {
        case TaskInfo = 0
        case Creator
        case PersonInCharge
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if currentUser!.roleCode == WISDataManager.sharedInstance().roleCodes[RoleCode.Operator.rawValue] {
            switch wisTask!.state {
            case TaskStateForOperator.Pending.rawValue:
                return 2
            default:
                return 3
            }
        }
        
        if currentUser!.roleCode == WISDataManager.sharedInstance().roleCodes[RoleCode.TechManager.rawValue]
            || currentUser!.roleCode == WISDataManager.sharedInstance().roleCodes[RoleCode.FieldManager.rawValue] {
            switch wisTask!.state {
            case TaskStateForOperator.Pending.rawValue:
                return 2
            case TaskStateForManager.ForArchive.rawValue, TaskStateForManager.Archived.rawValue:
                return 6
            default:
                return 5
            }
        }
        
        // 除生产人员、前方部长、技术主管外的其它角色
        switch wisTask!.state {
        case TaskStateForOperator.Pending.rawValue:
            return 2
        default:
            //备注信息何时显示？
            return 5
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .TaskBasicInfo:
            if wisTask?.state == TaskStateForOperator.Pending.rawValue || wisTask?.state == TaskStateForEngineer.Pending.rawValue {
                return 2
            } else {
                return 3
            }
        case .TaskDescription:
            return 1
        case .TaskHandleInfo:
            return planCount
        case .TaskState:
            return stateCount
        case .Remark:
            return 1
        case .Rating:
            if wisTask!.state == TaskStateForManager.ForArchive.rawValue || wisTask!.state == TaskStateForManager.Archived.rawValue {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .TaskBasicInfo:
            return 20
        case .TaskDescription:
            return 20
        case .TaskHandleInfo:
            if planCount == 0 {
                return 0
            } else {
                return 20
            }
        case .TaskState:
            return 20
        case .Remark:
            return 20
        case .Rating:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .Remark:
            return 20
        case .Rating:
            return 20
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
            
        case .TaskBasicInfo:
            
            switch indexPath.row {
                
            case BasicInfoRow.Creator.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(taskDetailSingleInfoCellID) as! TaskDetailSingleInfoCell
                
                cell.selectionStyle = .None
                cell.annotationLabel.text = NSLocalizedString("Creator")
                if wisTask!.creator == nil {
                    cell.annotationInfoLabel.text = NSLocalizedString("None", comment: "")
                } else {
                    if wisTask!.creator.fullName == nil || wisTask!.creator.fullName.isEmpty {
                        cell.annotationInfoLabel.text = NSLocalizedString("None", comment: "")
                    } else {
                        cell.annotationInfoLabel.text = wisTask?.creator.fullName
                    }
                }
                cell.annotationImageView.image = UIImage(named: "icon_user_create")
                return cell
                
            case BasicInfoRow.PersonInCharge.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(taskDetailSingleInfoCellID) as! TaskDetailSingleInfoCell
                
                cell.selectionStyle = .None
                cell.annotationLabel.text = NSLocalizedString("In Charge")
                if wisTask!.personInCharge == nil {
                    cell.annotationInfoLabel.text = NSLocalizedString("None", comment: "")
                } else {
                    if wisTask!.personInCharge.fullName == nil || wisTask!.personInCharge.fullName.isEmpty {
                        cell.annotationInfoLabel.text = NSLocalizedString("None", comment: "")
                    } else {
                        cell.annotationInfoLabel.text = wisTask?.personInCharge.fullName
                    }
                }
                cell.annotationImageView.image = UIImage(named: "icon_user_incharge")
                return cell
                
            case BasicInfoRow.TaskInfo.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(taskDetailDoubleInfoCellID) as! TaskDetailDoubleInfoCell
                
                cell.selectionStyle = .None
                cell.annotationLabel.text = NSLocalizedString("Index")
                cell.annotationInfoLabel.text = wisTask?.taskID
                cell.infoLabel.text = WISConfig.configureStateText(wisTask!.state)
                
                return cell
                
            default:
                return UITableViewCell()
            }
            
            
        case .TaskDescription:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskDescriptionCellID) as! TaskDescriptionCell
            
            cell.selectionStyle = .None

            cell.bind(wisTask!)
       
            return cell
            
        case .TaskHandleInfo:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskPlanCellID) as! TaskPlanCell
            
            cell.selectionStyle = .None
            
            if wisTask!.maintenancePlans.count <= 0 {
                cell.planDescriptionTextView.text = NSLocalizedString("None", comment: "")
                cell.estimatedDateLabel.text = ""
                cell.relevantUserTextView.text = NSLocalizedString("None", comment: "")
            } else {
                cell.bind(wisTask?.maintenancePlans[indexPath.row] as! WISMaintenancePlan, index: indexPath.row + 1)
            }

            return cell
            
        case .TaskState:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskStateCellID) as! TaskStateCell
            cell.selectionStyle = .None
            
            cell.bind(self.wisTask!.passedStates[indexPath.row] as! WISMaintenanceTaskState)
            return cell
            
        case .Remark:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskDetailLargeInfoCellID) as! TaskDetailLargeInfoCell
            
            cell.selectionStyle = .None
            cell.annotationLabel.text = NSLocalizedString("Remark", comment: "")
            
            if wisTask!.taskComment == nil {
                cell.infoTextView.text = NSLocalizedString("None", comment: "")
            } else {
                cell.infoTextView.text = wisTask!.taskComment
            }
            
            return cell
            
        case .Rating:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskRateCellID) as! TaskRateCell
            
            cell.selectionStyle = .None
            
            cell.bind(wisTask!.taskRating)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
            
        case .TaskBasicInfo:
            
            switch indexPath.row {
                
            case BasicInfoRow.Creator.rawValue:
                
                guard let cell = cell as? TaskDetailSingleInfoCell else {
                    break
                }

                // Phone Call Alert 有待进一步完善
                cell.tapToCallAction = {
                    if let telNumber = self.wisTask!.creator.telephoneNumber, mobileNumber = self.wisTask!.creator.cellPhoneNumber {
                        WISAlert.phoneCall(title: self.wisTask!.creator.fullName, telNumber: telNumber, mobileNumber: mobileNumber, inViewController: self, withTelCallAction: {
                            let phoneCallURL = NSURL(string: "tel://" + telNumber)!
                            UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, mobileCallAction: {
                                let phoneCallURL = NSURL(string: "tel://" + mobileNumber)!
                                UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, cancelAction: {})
                    }
                }
                
            case BasicInfoRow.PersonInCharge.rawValue:
                
                guard let cell = cell as? TaskDetailSingleInfoCell else {
                    break
                }
                
                cell.tapToCallAction = {
                    if let telNumber = self.wisTask!.personInCharge.telephoneNumber, mobileNumber = self.wisTask!.personInCharge.cellPhoneNumber {
                        WISAlert.phoneCall(title: self.wisTask!.personInCharge.fullName, telNumber: telNumber, mobileNumber: mobileNumber, inViewController: self, withTelCallAction: {
                            let phoneCallURL = NSURL(string: "tel://" + telNumber)!
                            UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, mobileCallAction: {
                                let phoneCallURL = NSURL(string: "tel://" + mobileNumber)!
                                UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, cancelAction: {})
                    }
                }
                
            default:
                return
                
            }
            
            
        case .TaskDescription:
            
            guard let cell = cell as? TaskDescriptionCell else {
                break
            }
            
            cell.tapMediaAction = { [weak self] transitionView, image, wisFileInfos, index in
                
                guard image != nil else {
                    return
                }
                
                let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewControllerWithIdentifier("MediaPreviewViewController") as! MediaPreviewViewController
                
                vc.previewImages = wisFileInfos
                vc.startIndex = index
                
                let transitionView = transitionView
                let frame = transitionView.convertRect(transitionView.frame, toView: self?.view)
                vc.previewImageViewInitalFrame = frame
                vc.bottomPreviewImage = image
                
                vc.transitionView = transitionView
                
                self?.view.endEditing(true)
                
                delay(0.3, work: { () -> Void in
                    transitionView.alpha = 0 // 加 Delay 避免图片闪烁
                })
                
                delay(0) {
                    transitionView.alpha = 0 // 放到下一个 Runloop 避免太快消失产生闪烁
                }
                
                vc.afterDismissAction = { [weak self] in
                    transitionView.alpha = 1
                    mediaPreviewWindow.hidden = true
                    self?.view.window?.makeKeyAndVisible()
                }
                
                mediaPreviewWindow.rootViewController = vc
//                mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
                mediaPreviewWindow.makeKeyAndVisible()
            }
            break
            
        case .TaskHandleInfo:
            
            guard let cell = cell as? TaskPlanCell else {
                break
            }
            
            cell.tapMediaAction = { [weak self] transitionView, image, wisFileInfos, index in
                
                guard image != nil else {
                    return
                }
                
                let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewControllerWithIdentifier("MediaPreviewViewController") as! MediaPreviewViewController
                
                vc.previewImages = wisFileInfos
                vc.startIndex = index
                
                let transitionView = transitionView
                let frame = transitionView.convertRect(transitionView.frame, toView: self?.view)
                vc.previewImageViewInitalFrame = frame
                vc.bottomPreviewImage = image
                
                vc.transitionView = transitionView
                
                self?.view.endEditing(true)
                
                delay(0.3, work: { () -> Void in
                    transitionView.alpha = 0 // 加 Delay 避免图片闪烁
                })
                
                delay(0) {
                    transitionView.alpha = 0 // 放到下一个 Runloop 避免太快消失产生闪烁
                }
                
                vc.afterDismissAction = { [weak self] in
                    transitionView.alpha = 1
                    mediaPreviewWindow.hidden = true
                    self?.view.window?.makeKeyAndVisible()
                }
                
                mediaPreviewWindow.rootViewController = vc
//                mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
                mediaPreviewWindow.makeKeyAndVisible()
            }
            break
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
            
        case Section.TaskBasicInfo.rawValue:
            return 44
            
        case Section.TaskDescription.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskDescriptionCellID) as! TaskDescriptionCell
            return cell.calHeightOfCell(wisTask!)
            
        case Section.TaskHandleInfo.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskPlanCellID) as! TaskPlanCell
            return cell.calHeightOfCell((wisTask!.maintenancePlans[indexPath.row] as! WISMaintenancePlan))
            
        case Section.Remark.rawValue:
            return 111
            
        case Section.TaskState.rawValue:
            return 60
            
        case Section.Rating.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskRateCellID) as! TaskRateCell
            return cell.calHeightOfCell(wisTask!.taskRating)
            
        default:
            return 0
        }
    }
    
}