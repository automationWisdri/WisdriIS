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
        
        let selectedRow = pickUserTableView.indexPathsForSelectedRows!
        
        for selectedPath in selectedRow {
            selectedUser.append(relevantUser[selectedPath.section + selectedPath.row])
        }
        
        switch segueIdentifier! {
        
        case "pickUserForSubmitPlan":
            
//            currentTask?.maintenancePlan.participants.addObjectsFromArray(selectedUser)

            // 跳转回维保方案页面，将选择的用户返回给页面的 taskParticipants 对象
            let destinationVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! SubmitPlanViewController
            destinationVC.taskParticipants = selectedUser
            self.navigationController?.popToViewController(destinationVC, animated: true)
            
        case "pickUserForModifyPlan":
            
            let destinationVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ModifyPlanViewController
            destinationVC.taskParticipants = selectedUser
            self.navigationController?.popToViewController(destinationVC, animated: true)
            
        case "pickUserForPassOperation":
            
            guard selectedUser.count == 1 else {
//                SVProgressHUD.showErrorWithStatus("只能选择 1 个用户")
                WISAlert.alertSorry(message: "只能选择 1 个用户", inViewController: self)
                return
            }
            
            SVProgressHUD.showWithStatus("正在提交")
//            print(selectedUser[0].userName)
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "转单", operationType: MaintenanceTaskOperationType.PassOn, taskReceiverName: selectedUser[0].userName, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    let status = "任务已转给：" + self.selectedUser[0].fullName
                    SVProgressHUD.showSuccessWithStatus(status)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                    
                }
            })
            
        case "assignUserForPassOperation":
            
            guard selectedUser.count == 1 else {
//                SVProgressHUD.showErrorWithStatus("只能选择 1 个用户")
                WISAlert.alertSorry(message: "只能选择 1 个用户", inViewController: self)
                return
            }
            
            SVProgressHUD.showWithStatus("正在提交")
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: "转单", operationType: MaintenanceTaskOperationType.Assign, taskReceiverName: selectedUser[0].userName, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    let status = "任务已转给：" + self.selectedUser[0].fullName
                    SVProgressHUD.showSuccessWithStatus(status)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                    
                }
            })
            
            
        default:
            return
            
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
        
        // 获取任务参与人员，分为工程师和电工
        WISDataManager.sharedInstance().updateRelavantUserInfoWithCompletionHandler { (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) in
            if completedWithNoError {
                
                let users: Array<WISUser> = updatedData as! Array<WISUser>
                
                self.engineerUser.removeAll()
                self.technicianUser.removeAll()
                self.relevantUser.removeAll()
                
                for user in users {
                    
                    self.relevantUser.append(user)
                    
                    switch user.roleCode {
                        
                    case "Engineer":
                        
                        self.engineerUser.append(user)
                        
                    case "Electrician":
                        
                        self.technicianUser.append(user)
                        
                    default: break
                        
                    }
                }
                
                for wisUser in self.relevantUser {
                    if self.taskParticipantsUsername.contains(wisUser.userName) {
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        break
                    }
                }
                
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
    /*
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let section = Section(rawValue: indexPath.section), let cell = cell as? ContactsCell else {
            return
        }
            
        if segueIdentifier == "pickUserForSubmitPlan" {
            switch section {
            
            case .Engineer:
                
                if taskParticipantsUsername.contains(self.engineerUser[indexPath.row].userName) {
//                    cell.setSelected(true, animated: false)
                    cell.selected = true
                }
                
            case .Technician:
                
                if taskParticipantsUsername.contains(self.technicianUser[indexPath.row].userName) {
//                    cell.setSelected(true, animated: false)
                    cell.selected = true
                }
            }
        }
        
    }
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !navigationItem.rightBarButtonItem!.enabled {
            navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if pickUserTableView.indexPathsForSelectedRows == nil || pickUserTableView.indexPathsForSelectedRows!.count == 0 {
            navigationItem.rightBarButtonItem!.enabled = false
        }
    }
}
