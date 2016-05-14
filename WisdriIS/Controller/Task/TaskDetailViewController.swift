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
    
    var wisTask: WISMaintenanceTask?
    var indexInList = 0
    var superViewController:UIViewController?
    
    var imagesInfo = [String : WISFileInfo]()
    var imagesArray = [UIImage]()
    var taskImagesFileInfoArray = [WISFileInfo]()
    var planImagesFileInfoArray = [WISFileInfo]()
    private var planCount = 0
    private var stateCount = 0
    
    private let pickUserSegueIdentifier = "pickUserForPassOperation"
    private let assignUserSegueIdentifier = "assignUserForPassOperation"
    private let submitQuickPlanSegueIdentifier = "submitQuickPlanOperation"
    private let submitPlanSegueIdentifier = "submitPlanOperation"
    private let modifyPlanSegueIdentifier = "modifyPlanOperation"
    private let approveSegueIdentifier = "approveOperation"
    private let recheckSegueIdentifier = "recheckOperation"
    
    private lazy var operationTypesView: OperationTypesView = {
        let view = OperationTypesView()
        
        // 技术主管归档
        view.archiveOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "归档", operationType: MaintenanceTaskOperationType.Archive, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("归档成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    errorCode(error)
                }
            })
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

        // 厂级负责人不同意方案
        view.rejectOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "拒绝", operationType: MaintenanceTaskOperationType.Reject, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("提交成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            })
        }
        
        // 工程师完成任务
        view.completeOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "维保完成", operationType: MaintenanceTaskOperationType.TaskComplete, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("提交成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            })
        }
        
        // 工程师转单
        view.passOperation = { [weak self] in
            self?.performSegueWithIdentifier("pickUser", sender: nil)
        }
        
        // 工程师接受转单
        view.acceptPassOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "接受转单", operationType: MaintenanceTaskOperationType.AcceptPassOnTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("接单成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                
                }
            })
        }
        
        // 工程师拒绝接受转单
        view.refusePassOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "拒绝转单", operationType: MaintenanceTaskOperationType.RefuseToReceiveTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("已拒绝转单请求")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                    
                }
            })
        }
        
        // 工程师接受指派转单
        view.acceptAssignedOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "接受指派转单", operationType: MaintenanceTaskOperationType.AcceptAssignedPassOnTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("接受成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                    
                }
            })
        }
        
        // 审批同意维保方案
        view.approveOperation = { [weak self] in
            // 厂级负责人审批同意维保方案
            if WISDataManager.sharedInstance().currentUser.roleName == "厂级负责人" {
                SVProgressHUD.showWithStatus("正在提交")
                WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "审批同意", operationType: MaintenanceTaskOperationType.Approve, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                    
                    if completedWithNoError {
                        SVProgressHUD.setDefaultMaskType(.None)
                        SVProgressHUD.showSuccessWithStatus("提交成功")
                        self?.navigationController?.popViewControllerAnimated(true)
                    
                    } else {
                    
                        errorCode(error)
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
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "接单", operationType: MaintenanceTaskOperationType.AcceptMaintenanceTask, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("接单成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            })
        }
        
        // 生产人员撤单
        view.repealOperation = { [weak self] in
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "撤单", operationType: MaintenanceTaskOperationType.Cancel, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("撤单成功")
                    self?.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            })
        }
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        title = NSLocalizedString("Task Detail", comment: "")
        
        taskDetailTableView.delegate = self
        taskDetailTableView.dataSource = self
        
        taskDetailTableView.registerNib(UINib(nibName: taskDetailSingleInfoCellID, bundle: nil), forCellReuseIdentifier: taskDetailSingleInfoCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskDetailDoubleInfoCellID, bundle: nil), forCellReuseIdentifier: taskDetailDoubleInfoCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskDetailLargeInfoCellID, bundle: nil), forCellReuseIdentifier: taskDetailLargeInfoCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskDescriptionCellID, bundle: nil), forCellReuseIdentifier: taskDescriptionCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskPlanCellID, bundle: nil), forCellReuseIdentifier: taskPlanCellID)
        taskDetailTableView.registerNib(UINib(nibName: taskStateCellID, bundle: nil), forCellReuseIdentifier: taskStateCellID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getTaskDetail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTaskDetail() {
        // 获取任务详情
        SVProgressHUD.show()
        
        WISDataManager.sharedInstance().updateMaintenanceTaskDetailInfoWithTaskID(wisTask?.taskID) { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completedWithNoError {
                self.wisTask = updatedData as? WISMaintenanceTask
                currentTask = self.wisTask
                WISUserDefaults.getCurrentTaskOperations()
                
                if currentTaskOperations.first?.operationName != NSLocalizedString("NULL Operation")  {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }

                // 获取任务图片
                self.taskImagesFileInfoArray.removeAll()
                
                for item : AnyObject in self.wisTask!.imagesInfo.allKeys {
//                    self.imagesInfo[item as! String] = self.wisTask!.imagesInfo.objectForKey(item) as? WISFileInfo
                    self.taskImagesFileInfoArray.append(self.wisTask!.imagesInfo.objectForKey(item) as! WISFileInfo)
                }
                
                // 获取方案图片
                if self.wisTask!.maintenancePlans != nil {
                    self.planCount = self.wisTask!.maintenancePlans.count
                    self.stateCount = self.wisTask!.passedStates.count
                }
                SVProgressHUD.dismiss()
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.taskDetailTableView.reloadData()
                }
                
            } else {
                errorCode(error)
            }
        }
    }
    
    @IBAction func createNewOperation(sender: AnyObject) {
        if let window = view.window {
            operationTypesView.showInView(window)
        }
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
            let vc = segue.destinationViewController as! ModifyPlanViewController
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
    }
    
    private enum BasicInfoRow: Int {
        case TaskInfo = 0
        case Creator
        case PersonInCharge
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch wisTask!.state {
        case "等待接单.":
            return 2
        case "提交维保方案.":
            return 3
        default:
            return 5
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .TaskBasicInfo:
            if wisTask?.state == "等待接单." {
                return 2
            } else {
                return 3
            }
        case .TaskDescription:
            return 1
        case .TaskHandleInfo:
            if wisTask?.state == "等待接单." {
                return 0
            } else {
                return planCount
            }
        case .TaskState:
            return stateCount
        case .Remark:
            return 1
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
            return 20
        case .TaskState:
            return 20
        case .Remark:
            return 20
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
                cell.annotationLabel.text = "创建人："
                if wisTask!.creator == nil {
                    cell.annotatinoInfoLabel.text = NSLocalizedString("None", comment: "")
                } else {
                    if wisTask!.creator.fullName == nil || wisTask!.creator.fullName.isEmpty {
                        cell.annotatinoInfoLabel.text = NSLocalizedString("None", comment: "")
                    } else {
                        cell.annotatinoInfoLabel.text = wisTask?.creator.fullName
                    }
                }
                return cell
                
            case BasicInfoRow.PersonInCharge.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(taskDetailSingleInfoCellID) as! TaskDetailSingleInfoCell
                
                cell.selectionStyle = .None
                cell.annotationLabel.text = "责任人："
                if wisTask!.personInCharge == nil {
                    cell.annotatinoInfoLabel.text = NSLocalizedString("None", comment: "")
                } else {
                    if wisTask!.personInCharge.fullName == nil || wisTask!.personInCharge.fullName.isEmpty {
                        cell.annotatinoInfoLabel.text = NSLocalizedString("None", comment: "")
                    } else {
                        cell.annotatinoInfoLabel.text = wisTask?.personInCharge.fullName
                    }
                    
//                    if wisTask!.personInCharge.cellPhoneNumber != nil {
//                        cell.getPhoneNumber(wisTask!.personInCharge.cellPhoneNumber)
//                    }
                    cell.getPhoneNumber("027-81996614")
                }
                
                return cell
                
            case BasicInfoRow.TaskInfo.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(taskDetailDoubleInfoCellID) as! TaskDetailDoubleInfoCell
                
                cell.selectionStyle = .None
                cell.annotationLabel.text = "编号："
                cell.annotationInfoLabel.text = wisTask?.taskID
                cell.infoLabel.text = wisTask?.state
                
                return cell
                
            default:
                return UITableViewCell()
            }
            
            
        case .TaskDescription:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskDescriptionCellID) as! TaskDescriptionCell
            
            cell.selectionStyle = .None

            cell.sectionNameLabel.text = wisTask?.processSegmentName
            cell.taskDescriptionTextView.text = wisTask?.taskApplicationContent
            cell.taskTimeLabel.text = DATE.stringFromDate(wisTask!.createdDateTime)
            cell.getImagesFileInfo(taskImagesFileInfoArray)
            
            return cell
            
        case .TaskHandleInfo:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskPlanCellID) as! TaskPlanCell
            
            cell.selectionStyle = .None
            
            if wisTask!.maintenancePlans.count <= 0 {
                cell.planDescriptionTextView.text = NSLocalizedString("None", comment: "")
                cell.estimatedDateLabel.text = ""
                cell.relevantUserTextView.text = NSLocalizedString("None", comment: "")
            } else {

                cell.planDescriptionTextView.text = (wisTask?.maintenancePlans[indexPath.row] as! WISMaintenancePlan).planDescription
                cell.estimatedDateLabel.text = DATE.stringFromDate((wisTask?.maintenancePlans[indexPath.row] as! WISMaintenancePlan).estimatedEndingTime)
                
                planImagesFileInfoArray.removeAll()
                
                for item : AnyObject in (self.wisTask!.maintenancePlans[indexPath.row] as! WISMaintenancePlan).imagesInfo.allKeys {
                    self.planImagesFileInfoArray.append((self.wisTask!.maintenancePlans[indexPath.row] as! WISMaintenancePlan).imagesInfo.objectForKey(item) as! WISFileInfo)
                }
                
                cell.getImagesFileInfo(planImagesFileInfoArray)
                
                let taskParticipants = (wisTask?.maintenancePlans[indexPath.row] as! WISMaintenancePlan).participants
                
                switch taskParticipants.count {
                case 0:
                    cell.relevantUserTextView.text = "无其他参与人员"
                default:
                    cell.relevantUserTextView.text = ""
                    for user in taskParticipants {
                        
                        if user as! NSObject == taskParticipants.lastObject as! WISUser {
                            cell.relevantUserTextView.text = cell.relevantUserTextView.text + user.fullName
                        } else {
                            cell.relevantUserTextView.text = user.fullName + "， " + cell.relevantUserTextView.text
                        }
                    }
                    cell.relevantUserTextView.text = "参与人员:  " + cell.relevantUserTextView.text
                }
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
            
            if wisTask!.taskDescription == nil {
                cell.infoTextView.text = NSLocalizedString("None", comment: "")
            } else {
                cell.infoTextView.text = wisTask!.taskDescription
            }
            
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
                // 个人觉得没必要显示座机，又增加了一次用户点击的操作
                // Phone Call Alert 有待进一步完善
                cell.tapToCallAction = {
                    if let telNumber = self.wisTask!.creator.telephoneNumber, mobileNumber = self.wisTask!.creator.cellPhoneNumber {
                        YepAlert.phoneCall(telNumber: telNumber, mobileNumber: mobileNumber, inViewController: self, withTelCallAction: {
                            let phoneCallURL = NSURL(string: "tel://" + telNumber)!
                            UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, mobileCallAction: {
                                let phoneCallURL = NSURL(string: "tel://" + mobileNumber)!
                                UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, cancelAction: {})
//                        YepAlert.confirmOrCancel(title: phoneNumber, message: "", confirmTitle: "呼叫", cancelTitle: "取消", inViewController: self, withConfirmAction: {
//                            let phoneCallURL = NSURL(string: "tel://" + phoneNumber)!
////                            print(phoneCallURL)
//                            UIApplication.sharedApplication().openURL(phoneCallURL)
//                            }, cancelAction: {})
                    }
                }
                
            case BasicInfoRow.PersonInCharge.rawValue:
                
                guard let cell = cell as? TaskDetailSingleInfoCell else {
                    break
                }
                
                cell.tapToCallAction = {
                    if let telNumber = self.wisTask!.personInCharge.telephoneNumber, mobileNumber = self.wisTask!.personInCharge.cellPhoneNumber {
                        YepAlert.phoneCall(telNumber: telNumber, mobileNumber: mobileNumber, inViewController: self, withTelCallAction: {
                            let phoneCallURL = NSURL(string: "tel://" + telNumber)!
                            UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, mobileCallAction: {
                                let phoneCallURL = NSURL(string: "tel://" + mobileNumber)!
                                UIApplication.sharedApplication().openURL(phoneCallURL)
                            }, cancelAction: {})
                    }
//                    if let phoneNumber = self.wisTask!.personInCharge.cellPhoneNumber {
//                        YepAlert.confirmOrCancel(title: phoneNumber, message: "", confirmTitle: "呼叫", cancelTitle: "取消", inViewController: self, withConfirmAction: {
//                            let phoneCallURL = NSURL(string: "tel://" + phoneNumber)!
//                            UIApplication.sharedApplication().openURL(phoneCallURL)
//                            }, cancelAction: {})
//                    }
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
                
//                vc.previewMedias = attachments.map({ PreviewMedia.AttachmentType(attachment: $0) })
//                vc.previewMedias = wisFileInfos.map({ PreviewMedia.WISFileInfoType(wisFileInfo: $0) })
                vc.previewImages = wisFileInfos
                vc.startIndex = index
                
                let transitionView = transitionView
                let frame = transitionView.convertRect(transitionView.frame, toView: self?.view)
                vc.previewImageViewInitalFrame = frame
                vc.bottomPreviewImage = image
                
                vc.transitionView = transitionView
                
//                self?.view.endEditing(true)
                
//                delay(0.3, work: { () -> Void in
//                    transitionView.alpha = 0 // 加 Delay 避免图片闪烁
//                })
                
                delay(0) {
                    transitionView.alpha = 0 // 放到下一个 Runloop 避免太快消失产生闪烁
                }
                
                vc.afterDismissAction = { [weak self] in
                    transitionView.alpha = 1
                    mediaPreviewWindow.hidden = true
                    self?.view.window?.makeKeyAndVisible()
                }
                
                mediaPreviewWindow.rootViewController = vc
                mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
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
//            switch indexPath.row {
//                
//            case BasicInfoRow.TaskInfo.rawValue:
//                return 44
//                
//            case BasicInfoRow.Double.rawValue:
//                return 44
//                
//            default:
//                return 0
//            }
            
        case Section.TaskDescription.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskDescriptionCellID) as! TaskDescriptionCell
            
            return cell.heightOfCell(cell.taskDescriptionTextView.text)
            
        case Section.TaskHandleInfo.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(taskPlanCellID) as! TaskPlanCell
            
            return cell.heightOfCell(cell.planDescriptionTextView.text, user: cell.relevantUserTextView.text)
            
        case Section.Remark.rawValue:
            return 111
            
        case Section.TaskState.rawValue:
            return 60
            
        default:
            
            return 10
        }
    }
    
}