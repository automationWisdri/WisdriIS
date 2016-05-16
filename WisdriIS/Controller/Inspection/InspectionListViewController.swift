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

class InspectionListViewController : BaseViewController {
    
    // var inspectionTasks = [WISInspectionTask]()
    
    @IBOutlet weak var inspectionTableView: UITableView!
    // 导航栏右侧弹出菜单
    var inspectionPopoverButton:UIBarButtonItem?
    
    var inspectionPopoverMenuController:InspectionPopoverMenuController?
//    var inspectionPopoverPresentationController:UIPopoverPresentationController?
    // 搜索栏
    var inspectionSearchBar: UISearchBar?
    
    var blurEffectView: UIVisualEffectView?
    
    private let inspectionListCellID = "InspectionListCell"
    private let inspectionDetailViewSegueID = "showInspectionDetail"
    private var codeScanNotificationToken : String?
    
    var inspectionOperationEnabled = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // self.inspectionSearchBar.delegate = self
        
        inspectionTableView.delegate = self
        inspectionTableView.dataSource = self
        
        title = NSLocalizedString("Inpection Task List")
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector:#selector(self.parseScanedCode(_:)),
                                                         name: QRCodeScanedSuccessfullyNotification,
                                                         object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) registered in InspectionDetailViewController while loading view")
        
        
        /// *** right button item on navigationbar
        // inspectionPopoverButton = UIBarButtonItem.init(title: "Menu", style: .Plain, target: self, action: #selector(self.pushScanView(_:)))
        inspectionPopoverButton = UIBarButtonItem.init(barButtonSystemItem: .Bookmarks, target: self, action: #selector(self.popoverMenu(_:)))
        self.navigationItem.rightBarButtonItem = inspectionPopoverButton

        // *** Popover menu controller
        inspectionPopoverMenuController = InspectionPopoverMenuController()
        inspectionPopoverMenuController!.modalPresentationStyle = .Popover
        // inspectionPopoverMenuController!.color
        // inspectionPopoverMenuController!.preferredStatusBarUpdateAnimation()
        inspectionPopoverMenuController!.preferredContentSize = inspectionPopoverMenuController!.menuTableViewPreferedSize
        inspectionPopoverMenuController!.PopoverSuperController = self
        
        inspectionPopoverMenuController!.PopoverMenuItemTapedCompletion = {
            (menuItem:InspectionPopoverMenuItem) -> Void in
            weak var weakSelf = self
            /// REMARK: before presenting a view Controller, you should dismiss current presenting one
            weakSelf!.inspectionPopoverMenuController!.dismissInspectionPopoverMenu()
            
            switch menuItem {
            case .ScanQRCode:
                self.codeScanNotificationToken = CodeScanViewController.performPresentToCodeScanViewController(self) {
                    self.blurEffectView?.removeFromSuperview()
                    print("presenting Code Scan View")
                }
                
                print("code scan notification token: \n\(self.codeScanNotificationToken)")
                break
                
            case .UploadingQueue:
                InspectionUploadingQueueViewController.performSegueToInspectionUploadingQueueViewController(self) {
                    print("segue InspectionUploadingQueueViewController")
                    weakSelf!.blurEffectView?.removeFromSuperview()
                    print("show Inspection Uploading Queue View")
                }
                break
                
            case .HistoricalInspection:
                break
            }
        }
        
        
        /// *** search bar setting
        inspectionSearchBar = UISearchBar()
        //inspectionSearchBar.prompt = "prompt"
        inspectionSearchBar!.placeholder = NSLocalizedString("placeholder")
        inspectionSearchBar!.setShowsCancelButton(false, animated: true)
        inspectionSearchBar!.barStyle = .Default
        inspectionSearchBar!.returnKeyType = .Search
        inspectionSearchBar!.showsScopeBar = false
        inspectionSearchBar!.sizeToFit()
        // inspectionTableView.tableHeaderView = inspectionSearchBar
        
        /// *** blurEffect
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        blurEffectView?.alpha = 0.85
        
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
    @objc func parseScanedCode(notification:NSNotification) -> Void {
        if (notification.userInfo![codeScanNotificationTokenKey] as! String) == self.codeScanNotificationToken {
            // do checking jobs
            print("InspectionListViewController- code:\(notification.object)")
            
            let scanResult = notification.object as! String
            let scanResultAsArray = scanResult.componentsSeparatedByString("&")
            
            guard scanResultAsArray[0] == "DEVICE" && scanResultAsArray.count == 7 else {
                YepAlert.alert(title: NSLocalizedString("QRCode content not match", comment: ""), message: NSLocalizedString("Scaned QRCode is ", comment: "") + scanResult, dismissTitle: NSLocalizedString("Confirm", comment: ""), inViewController: self, withDismissAction: {
                    // do nothing
                })
                return
            }
            
            let deviceID = scanResultAsArray[1]
            let deviceName = scanResultAsArray[2]
            let deviceCode = scanResultAsArray[3]
            let company = scanResultAsArray[4]
            let processSegment = scanResultAsArray[5]
            let deviceTypeID = scanResultAsArray[6]
            
            let index = WISInsepctionDataManager.sharedInstance().indexOfInspectionTaskInListByDeviceID(deviceID)
            
            SVProgressHUD.show()
            
            if index > -1 {
                InspectionDetailViewController.performSegueToInspectionDetailView(self, inspectionTask: WISInsepctionDataManager.sharedInstance().inspectionTasks[index], index: index, needToScanCode: false, enableOperation: inspectionOperationEnabled)
                
            } else {
                var newInspectionTask = WISInspectionTask()
                
                if WISDataManager.sharedInstance().networkReachabilityStatus != .NotReachable && WISDataManager.sharedInstance().networkReachabilityStatus != .Unknown {
                    WISDataManager.sharedInstance().updateInspectionInfoWithDeviceID(deviceID, completionHandler: { [weak self]
                        (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) in
                        if completedWithNoError {
                            print("receive inspection info of device (deviceID): \(deviceID) successfully!")
                            let task = updatedData as! WISInspectionTask
                            newInspectionTask = task.copy() as! WISInspectionTask
                            
                        } else {
                            print("receive inspection info of device (deviceID): \(deviceID) failed!")
                            newInspectionTask.device.deviceID = deviceID
                            newInspectionTask.device.deviceName = deviceName
                            newInspectionTask.device.deviceCode = deviceCode
                            newInspectionTask.device.company = company
                            newInspectionTask.device.processSegment = processSegment
                        }
                        
                        let deviceType = WISInsepctionDataManager.sharedInstance().deviceTypes[deviceTypeID]
                        
                        if deviceType != nil {
                            newInspectionTask.device.deviceType = deviceType!.copy() as! WISDeviceType
                        }
                        
                        InspectionDetailViewController.performSegueToInspectionDetailView(self!, inspectionTask: newInspectionTask, index: -1, needToScanCode: false, enableOperation: self!.inspectionOperationEnabled)
                        
                    })
                    
                } else {
                    newInspectionTask.device.deviceID = deviceID
                    newInspectionTask.device.deviceName = deviceName
                    newInspectionTask.device.deviceCode = deviceCode
                    newInspectionTask.device.company = company
                    newInspectionTask.device.processSegment = processSegment
                    
                    
                    let deviceType = WISInsepctionDataManager.sharedInstance().deviceTypes[deviceTypeID]
                    
                    if deviceType != nil {
                        newInspectionTask.device.deviceType = deviceType!.copy() as! WISDeviceType
                    }
                    
                    InspectionDetailViewController.performSegueToInspectionDetailView(self, inspectionTask: newInspectionTask, index: -1, needToScanCode: false, enableOperation: inspectionOperationEnabled)
                }
            }
            SVProgressHUD.dismiss()
        }
        return
    }
    
    
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
        SVProgressHUD.setDefaultMaskType(.None)
        SVProgressHUD.showWithStatus(NSLocalizedString("Updating inspection task list", comment: ""))
        
        WISDataManager.sharedInstance().updateInspectionsInfoWithCompletionHandler { (completionWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            if completionWithNoError {
                let inspectionTasks: [WISInspectionTask] = updatedData as! [WISInspectionTask]
                WISInsepctionDataManager.sharedInstance().inspectionTasks.removeAll()
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
                        WISInsepctionDataManager.sharedInstance().inspectionTasks.append(task)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.inspectionTableView.reloadData()
                }
                
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Inspection task list updated successfully", comment: ""))
                
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: QRCodeScanedSuccessfullyNotification, object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) deregistered in InspectionListViewController while deiniting")
    }
    
    
    func popoverMenu(sender: UIBarButtonItem) {
        
        let inspectionPopoverPresentationController = inspectionPopoverMenuController!.popoverPresentationController
        inspectionPopoverPresentationController!.permittedArrowDirections = .Up
        inspectionPopoverPresentationController!.backgroundColor = inspectionPopoverMenuController!.menuTableViewForeGroundColor
        
        /// MARK: expression below use the position of barButtonItem to locate the Popover
        /// 
        // inspectionPopoverPresentationController!.barButtonItem = sender
        inspectionPopoverPresentationController!.delegate = self
        inspectionPopoverPresentationController!.sourceView = self.view
        var frame:CGRect = sender.valueForKey("view")!.frame
        frame.origin.y += 20
        frame.origin.x -= 4
        inspectionPopoverPresentationController!.sourceRect = frame
        
        inspectionPopoverMenuController!.menuTableView?.reloadData()
        
        print("Presentation Style: \(inspectionPopoverPresentationController?.presentationStyle.rawValue)")
        self.presentViewController(inspectionPopoverMenuController!, animated: true) {
            self.blurEffectView!.frame = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.window?.bounds)! //self.view.bounds
            self.view.addSubview(self.blurEffectView!)
        }
    }
}

// MARK: - Table view data source & delegate method

extension InspectionListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WISInsepctionDataManager.sharedInstance().inspectionTasks.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: InspectionListCell.self, indexPath: indexPath)
        cell.bindData(WISInsepctionDataManager.sharedInstance().inspectionTasks[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let task = WISInsepctionDataManager.sharedInstance().inspectionTasks[indexPath.row]
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // performSegueWithIdentifier(inspectionDetailViewSegueID, sender: equipment)
        InspectionDetailViewController.performSegueToInspectionDetailView(self, inspectionTask: task, index:indexPath.row,needToScanCode: true, enableOperation: inspectionOperationEnabled)
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



extension InspectionListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("popoverPresentationControllerShouldDismissPopover")
        self.blurEffectView?.removeFromSuperview()
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        print("popoverPresentationControllerDidDismissPopover")
    }
    
    
}