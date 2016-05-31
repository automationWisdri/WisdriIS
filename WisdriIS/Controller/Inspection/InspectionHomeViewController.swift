//
//  InspectionHomeViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/18/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//


import UIKit
import SVProgressHUD
import PagingMenuController

class InspectionHomeViewController: BaseViewController {
    
    private let currentUser = WISDataManager.sharedInstance().currentUser
    private let roleCodes = WISDataManager.sharedInstance().roleCodes
    
    // 导航栏右侧弹出菜单
    var inspectionPopoverButton:UIBarButtonItem?
    
    var inspectionPopoverMenuController:InspectionPopoverMenuController?
    //    var inspectionPopoverPresentationController:UIPopoverPresentationController?
    // 搜索栏
    var inspectionSearchBar: UISearchBar?
    // 模糊效果
    var blurEffectView: UIVisualEffectView?
    let alphaOfBlurEffect: CGFloat = 0.85
    
    private var codeScanNotificationToken : String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector:#selector(self.parseScanedCode(_:)),
                                                         name: QRCodeScanedSuccessfullyNotification,
                                                         object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) registered in InspectionHomeViewController while loading view")
        
        /// *** right button item on navigationbar

        // inspectionPopoverButton = UIBarButtonItem.init(barButtonSystemItem: .Bookmarks, target: self, action: #selector(self.popoverMenu(_:)))
        inspectionPopoverButton = UIBarButtonItem.init(image: UIImage(named: "icon_more"), style: .Plain, target: self, action: #selector(self.popoverMenu(_:)))
        
        if self.currentUser.roleCode == self.roleCodes[RoleCode.Engineer.rawValue] || self.currentUser.roleCode == self.roleCodes[RoleCode.Technician.rawValue]{
            self.navigationItem.rightBarButtonItem = inspectionPopoverButton
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
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
                    weakSelf!.disappearBlurEffect(0.0)
                    print("presenting Code Scan View")
                }
                
                print("code scan notification token: \n\(self.codeScanNotificationToken)")
                break
                
            case .UploadingQueue:
                InspectionUploadingQueueViewController.performPushToInspectionUploadingQueueViewController(self) {
                    print("segue InspectionUploadingQueueViewController")
                    weakSelf!.disappearBlurEffect(0.0)
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
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
        blurEffectView?.backgroundColor = UIColor.lightGrayColor()
        
        let storyboard = UIStoryboard(name: "InspectionList", bundle: nil)
        
        // on the go inspection task list view
        let onTheGoInspectionTaskList = storyboard.instantiateViewControllerWithIdentifier("InspectionListViewController") as! InspectionListViewController
        // historical inspection task list view
        let historicalInspectionTaskList = storyboard.instantiateViewControllerWithIdentifier("InspectionListViewController") as! InspectionListViewController
        // over due inspection task list view
        let overDueInspectionTaskList = storyboard.instantiateViewControllerWithIdentifier("InspectionListViewController") as! InspectionListViewController
        
        onTheGoInspectionTaskList.inspectionTaskType = .OnTheGo
        onTheGoInspectionTaskList.showMoreInformation = false
        onTheGoInspectionTaskList.inspectionOperationEnabled = true
        onTheGoInspectionTaskList.title = NSLocalizedString("On the go inspection task", comment: "")
        
        historicalInspectionTaskList.inspectionTaskType = .Historical
        historicalInspectionTaskList.showMoreInformation = true
        historicalInspectionTaskList.inspectionOperationEnabled = false
        historicalInspectionTaskList.title = NSLocalizedString("Historical inspection task", comment: "")
        
        overDueInspectionTaskList.inspectionTaskType = .OverDue
        overDueInspectionTaskList.showMoreInformation = false
        overDueInspectionTaskList.inspectionOperationEnabled = false
        overDueInspectionTaskList.title = NSLocalizedString("Over due inspection task", comment: "")
        
        var viewControllers = [InspectionListViewController]()
        
        // for test
        print(WISDataManager.sharedInstance().currentUser.roleCode)
        
        let options = PagingMenuOptions()
        let role: Int? = roleCodes.indexOf(currentUser.roleCode)
        
        if role != nil {
            let roleCode = RoleCode(rawValue: role!)!
            switch roleCode {
            case .Operator, .TechManager, .DutyManager, .FactoryManager:
                viewControllers = [historicalInspectionTaskList]
                options.menuHeight = 0
                break
                
            case .FieldManager:
                viewControllers = [overDueInspectionTaskList, historicalInspectionTaskList]
                options.menuHeight = 40
                break
                
            case .Engineer, .Technician:
                viewControllers = [onTheGoInspectionTaskList, historicalInspectionTaskList]
                options.menuHeight = 40
                break
            }
        }
        
        self.navigationItem.title = viewControllers.count > 1 ? NSLocalizedString("Inpection Task List", comment: "") : viewControllers[0].title
        // options.menuItemMargin = 1
        // options.menuDisplayMode = .SegmentedControl
        
        // options.menuDisplayMode = .Standard(widthMode: PagingMenuOptions.MenuItemWidthMode.Fixed(width: 60), centerItem: false, scrollingMode: PagingMenuOptions.MenuScrollingMode.ScrollEnabledAndBouces)
        // options.menuDisplayMode = .Standard(widthMode: PagingMenuOptions.MenuItemWidthMode.Fixed(width: self.view.bounds.width / CGFloat(viewControllers.count)), centerItem: false, scrollingMode: PagingMenuOptions.MenuScrollingMode.ScrollEnabledAndBouces)
        
        options.menuDisplayMode = .SegmentedControl
        
        options.menuItemMode = .Underline(height: 1.5, color: UIColor.wisTintColor(), horizontalPadding: 1.5, verticalPadding: 1.5)
        options.font = UIFont.systemFontOfSize(15)
        options.selectedFont = UIFont.systemFontOfSize(16)
        options.lazyLoadingPage = .Three
        
        options.textColor = UIColor.wisGrayColor()
        options.selectedTextColor = UIColor.wisTintColor()
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(viewControllers: viewControllers, options: options)
        
        pagingMenuController.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        let currentViewController = pagingMenuController.currentViewController as! InspectionListViewController
        
        currentViewController.inspectionTableView.scrollsToTop = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: QRCodeScanedSuccessfullyNotification, object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) deregistered in InspectionListViewController while deiniting")
    }
    
    @objc func parseScanedCode(notification:NSNotification) -> Void {
        if (notification.userInfo![codeScanNotificationTokenKey] as! String) == self.codeScanNotificationToken {
            // do checking jobs
            print("InspectionListViewController- code:\(notification.object)")
            
            let scanResult = notification.object as! String
            let scanResultAsArray = scanResult.componentsSeparatedByString("&")
            
            guard scanResultAsArray[0] == "DEVICE" && scanResultAsArray.count == 7 else {
                WISAlert.alert(title: NSLocalizedString("QRCode content not match", comment: ""), message: NSLocalizedString("Scaned QRCode is ", comment: "") + scanResult, dismissTitle: NSLocalizedString("Confirm", comment: ""), inViewController: self, withDismissAction: {
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
            
            let index = WISInsepctionDataManager.sharedInstance().indexOfInspectionTaskInListByDeviceID(deviceID, inspectionTaskType: .OnTheGo)
            
            SVProgressHUD.show()
            
            if index > -1 {
                InspectionDetailViewController.performPushToInspectionDetailView(self, inspectionTask: WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks[index], index: index, showMoreInformation: true, enableOperation: true)
                
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
                        
                        InspectionDetailViewController.performPushToInspectionDetailView(self!, inspectionTask: newInspectionTask, index: -1, showMoreInformation: true, enableOperation: true)
                        
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
                    
                    InspectionDetailViewController.performPushToInspectionDetailView(self, inspectionTask: newInspectionTask, index: -1, showMoreInformation: true, enableOperation: true)
                }
            }
            SVProgressHUD.dismiss()
        }
        return
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
        frame.origin.x -= 6
        inspectionPopoverPresentationController!.sourceRect = frame
        
        inspectionPopoverMenuController!.menuTableView?.reloadData()
        
        print("Presentation Style: \(inspectionPopoverPresentationController?.presentationStyle.rawValue)")
        self.presentViewController(inspectionPopoverMenuController!, animated: true) {
            self.presentBlurEffect(self.alphaOfBlurEffect)
        }
    }
    
    
    private func presentBlurEffect(finishedAlpha: CGFloat) -> Void {
        self.blurEffectView!.frame = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.window?.frame)! //self.view.bounds
        self.blurEffectView?.alpha = 0.0
        self.parentViewController?.parentViewController?.view.addSubview(self.blurEffectView!)
        
        UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveLinear, animations: {
            self.blurEffectView?.alpha = finishedAlpha
            }, completion: { finished in
                // do nothing
        })
    }
    
    
    private func disappearBlurEffect(finishedAlpha: CGFloat) -> Void {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {
            self.blurEffectView?.alpha = finishedAlpha
            }, completion: { finished in
                self.blurEffectView!.removeFromSuperview()
        })
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


extension InspectionHomeViewController: PagingMenuControllerDelegate {
    
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        let didAppearViewController = menuController as! InspectionListViewController
        let previousViewController = previousMenuController as! InspectionListViewController
        
        didAppearViewController.inspectionTableView.scrollsToTop = true
        previousViewController.inspectionTableView.scrollsToTop = false
    }
}


extension InspectionHomeViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("popoverPresentationControllerShouldDismissPopover")
        self.disappearBlurEffect(0.0)
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        print("popoverPresentationControllerDidDismissPopover")
    }
}
