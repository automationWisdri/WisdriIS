//
//  PickUserViewController.swift
//  WisdriIS
//
//  Created by Allen on 3/28/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

class PickUserViewController: UIViewController {
    
    @IBOutlet weak var pickUserTableView: UITableView!
    
    @IBAction func doneAction(sender: AnyObject) {
        selectedUser.removeAll()
        let selectedRow = pickUserTableView.indexPathsForSelectedRows
        
        if selectedRow != nil {
            for selectedPath in selectedRow! {
                selectedUser.append(relevantUser[selectedPath.section + selectedPath.row])
            }
        }
        
        switch segueIdentifier! {
        case "pickUserForSubmitPlan":
            // currentTask?.maintenancePlan.participants.addObjectsFromArray(selectedUser)
            
            // 跳转回维保方案页面，将选择的用户返回给页面的 taskParticipants 对象
            let destinationVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! SubmitPlanViewController
            destinationVC.taskParticipants = selectedUser
            self.navigationController?.popToViewController(destinationVC, animated: true)
            break
            
        case "pickUserForModifyPlan":
            let destinationVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ModifyPlanViewController
            destinationVC.taskParticipants = selectedUser
            self.navigationController?.popToViewController(destinationVC, animated: true)
            break
            
        case "pickUserForPassOperation", "assignUserForPassOperation":
            guard selectedUser.count == 1 else {
                //                SVProgressHUD.showErrorWithStatus("只能选择 1 个用户")
                // YepAlert.Sorry(message: "必须选择 1 名用户", inViewController: self)
                WISAlert.alert(title: NSLocalizedString("Wrong Operation", comment: ""), message: NSLocalizedString("One and only one user should be seleceted", comment: ""), dismissTitle: NSLocalizedString("Confirm", comment: ""), inViewController: self, withDismissAction: nil)
                return
            }
            
            let opType = segueIdentifier! == "pickUserForPassOperation" ? MaintenanceTaskOperationType.PassOn : MaintenanceTaskOperationType.Assign
            
            SVProgressHUD.showWithStatus(NSLocalizedString("Submitting in progress", comment: ""))
            //            print(selectedUser[0].userName)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "转单", operationType: opType, taskReceiverName: selectedUser[0].userName, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    let status = NSLocalizedString("Task has been passed to ", comment: "") + self.selectedUser[0].fullName
                    SVProgressHUD.showSuccessWithStatus(status)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    WISConfig.errorCode(error)
                    
                }
            })
            break
            
        default:
            return
        }
    }
    
    private lazy var noRecordsFooterView: InfoView = InfoView(NSLocalizedString("人员列表获取失败。", comment: ""))
    
    private var noRecords = false {
        didSet {
            if noRecords != oldValue {
                pickUserTableView.tableFooterView = noRecords ? noRecordsFooterView : UIView()
            }
        }
    }
    
    var segueIdentifier: String?
    private let cellIdentifier = "ContactsCell"
    
    private var relevantUser = [WISUser]()
    private var engineerUser = [WISUser]()
    private var technicianUser = [WISUser]()
    private var selectedUser = [WISUser]()
    
    var taskParticipantsUsername = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = NSLocalizedString("Pick User", comment: "")
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.wisBackgroundColor()
        
        pickUserTableView.separatorColor = UIColor.wisCellSeparatorColor()
        pickUserTableView.separatorInset = WISConfig.ContactsCell.separatorInset
        
        pickUserTableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        pickUserTableView.rowHeight = 80
        pickUserTableView.tableFooterView = UIView()
        
        pickUserTableView.delegate = self
        pickUserTableView.dataSource = self
        
        pickUserTableView.setEditing(true, animated: false)
        pickUserTableView.allowsMultipleSelectionDuringEditing = true
        
        // doAction button should always enabled
        navigationItem.rightBarButtonItem!.enabled = true
        
        SVProgressHUD.showWithStatus(NSLocalizedString("Updating relevant user list", comment: ""))
        // 获取任务参与人员，分为工程师和电工
        WISDataManager.sharedInstance().updateRelavantUserInfoWithCompletionHandler { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) in
            if completedWithNoError {
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Relevant user list updating successfully", comment: ""))
                let users = updatedData as! [WISUser]
                
                self.engineerUser.removeAll()
                self.technicianUser.removeAll()
                self.relevantUser.removeAll()
                
                if users.count > 0 {
                    for user in users {
                        self.relevantUser.append(user)
                        
                        switch user.roleCode {
                        case WISDataManager.sharedInstance().roleCodes[RoleCode.Engineer.rawValue]:
                            self.engineerUser.append(user)
                            
                        case WISDataManager.sharedInstance().roleCodes[RoleCode.Technician.rawValue]:
                            self.technicianUser.append(user)
                            
                        default: break
                        }
                    }
                }
                
                if self.relevantUser.count > 0 {
                    for wisUser in self.relevantUser {
                        if self.taskParticipantsUsername.contains(wisUser.userName) {
                            // self.navigationItem.rightBarButtonItem?.enabled = true
                            break
                        }
                    }
                }
                
                self.noRecords = self.relevantUser.isEmpty
                self.pickUserTableView.reloadData()
                
                var indexPath: NSIndexPath
                for (index, wisUser) in self.engineerUser.enumerate() {
                    if self.taskParticipantsUsername.contains(wisUser.userName) {
                        indexPath = NSIndexPath(forRow: index, inSection: 0)
                        self.pickUserTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                    }
                }
                
                for (index, wisUser) in self.technicianUser.enumerate() {
                    if self.taskParticipantsUsername.contains(wisUser.userName) {
                        indexPath = NSIndexPath(forRow: index, inSection: 1)
                        self.pickUserTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                    }
                }
                
            } else {
                WISConfig.errorCode(error)
                self.noRecords = self.relevantUser.isEmpty
                self.pickUserTableView.reloadData()
            }
        }
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

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PickUserViewController: UITableViewDataSource, UITableViewDelegate {
    
    private enum Section: Int {
        case Engineer
        case Technician
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        switch segueIdentifier! {
            case "pickUserForSubmitPlan": return 2
            case "pickUserForModifyPlan": return 2
            case "pickUserForPassOperation": return 1
            case "assignUserForPassOperation": return 1
            default: return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch segueIdentifier! {
            
            case "pickUserForSubmitPlan":
                switch section {
                    case .Engineer: return engineerUser.count
                    case .Technician: return technicianUser.count
                }
            case "pickUserForModifyPlan":
                switch section {
                    case .Engineer: return engineerUser.count
                    case .Technician: return technicianUser.count
                }
            case "pickUserForPassOperation": return engineerUser.count
            case "assignUserForPassOperation": return engineerUser.count
            default: return 0
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch segueIdentifier! {
            
        case "pickUserForSubmitPlan":
            switch section {
            case .Engineer: return 20
            case .Technician: return 20
            }
        case "pickUserForModifyPlan":
            switch section {
            case .Engineer: return 20
            case .Technician: return 20
            }
        case "pickUserForPassOperation": return 0
        case "assignUserForPassOperation": return 0
        default: return 0
        }
        
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        guard let section = Section(rawValue: section) else {
//            return ""
//        }
//
//        switch section {
//        case .Engineer: return "工程师"
//        case .Technician: return "电工"
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let cell = getCell(tableView, cell: ContactsCell.self, indexPath: indexPath)
        
        switch segueIdentifier! {
            
        case "pickUserForSubmitPlan":
            switch section {
            case .Engineer:
                cell.bind(self.engineerUser[indexPath.row])
                return cell
            case .Technician:
                cell.bind(self.technicianUser[indexPath.row])
                return cell
            }
        case "pickUserForModifyPlan":
            switch section {
            case .Engineer:
                cell.bind(self.engineerUser[indexPath.row])
                return cell
            case .Technician:
                cell.bind(self.technicianUser[indexPath.row])
                return cell
            }
        case "assignUserForPassOperation":
            cell.bind(self.engineerUser[indexPath.row])
            return cell
        case "pickUserForPassOperation":
            cell.bind(self.engineerUser[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !navigationItem.rightBarButtonItem!.enabled {
            // navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if pickUserTableView.indexPathsForSelectedRows == nil || pickUserTableView.indexPathsForSelectedRows!.count == 0 {
            // navigationItem.rightBarButtonItem!.enabled = false
        }
    }
}