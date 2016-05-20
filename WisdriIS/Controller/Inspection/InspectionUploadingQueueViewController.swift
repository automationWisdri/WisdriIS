//
//  InspectionUploadingQueueViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/25/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

class InspectionUploadingQueueViewController: BaseViewController {

    // MARK: - Properties
    
    @IBOutlet weak var inspectionUploadingQueueTableView: UITableView!
    
    var inspectionUploadingRightButton: UIBarButtonItem?
    var superViewController: UIViewController? = nil
    
    private let InspectionUploadingQueueCellID = "InspectionUploadingQueueCell"
    
    
    // MARK: - View Life Cycle Operation Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        inspectionUploadingQueueTableView.delegate = self
        inspectionUploadingQueueTableView.dataSource = self
        
        title = NSLocalizedString("Inpection Uploading List")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inspectionTaskUploadingStateDidChanged(_:)), name: InspectionTaskUploadingStateChangedNotification, object: nil)
        
        /// *** right button item on navigationbar
        // inspectionPopoverButton = UIBarButtonItem.init(title: "Menu", style: .Plain, target: self, action: #selector(self.pushScanView(_:)))
        inspectionUploadingRightButton = UIBarButtonItem.init(barButtonSystemItem: .Action, target: self, action: #selector(self.startInspectionTaskUploading(_:)))
        self.navigationItem.rightBarButtonItem = inspectionUploadingRightButton
        
        /// *** list setting
        inspectionUploadingQueueTableView.registerNib(UINib(nibName: InspectionUploadingQueueCellID, bundle: nil), forCellReuseIdentifier: InspectionUploadingQueueCellID)
        
        inspectionUploadingQueueTableView.separatorColor = UIColor.wisCellSeparatorColor()
        inspectionUploadingQueueTableView.separatorInset = WISConfig.ContactsCell.separatorInset
        // inspectionUploadingQueueTableView.tableHeaderView = inspectionSearchBar
        
        inspectionUploadingQueueTableView.tableFooterView = UIView()
        
        inspectionUploadingQueueTableView.mj_header = WISRefreshHeader(refreshingBlock: {[weak self] () -> Void in
            self?.refresh()
            })
        self.refreshPage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("InspectionUploadingQueueViewController's view will appear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("InspectionUploadingQueueViewController's view did appear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("InspectionUploadingQueueViewController's view did disappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: InspectionTaskUploadingStateChangedNotification, object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) deregistered in InspectionDetailViewController while deiniting")
    }
    
    // MARK: - Methods
    
    func refreshPage(){
        inspectionUploadingQueueTableView.mj_header.beginRefreshing()
    }
    
    func refresh(){
        if WISDataManager.sharedInstance().networkReachabilityStatus != .NotReachable && WISDataManager.sharedInstance().networkReachabilityStatus != .Unknown {
            startInspectionTaskUploading(nil)

        } else {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showErrorWithStatus(NSLocalizedString("Networking Not Reachable"))
        }
        
        inspectionUploadingQueueTableView.mj_header.endRefreshing()
    }
    
    func startInspectionTaskUploading(sender: UIBarButtonItem?) -> Void {
        print("start inspection task uploading button pressed!")
        WISInsepctionDataManager.sharedInstance().startInspectionTaskUploading()
    }
    
    func inspectionTaskUploadingStateDidChanged(notification: NSNotification) -> Void {
        guard inspectionUploadingQueueTableView.visibleCells.count > 0 else {
            return
        }
        
        let cell = inspectionUploadingQueueTableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0)) as? InspectionUploadingQueueCell
        let stateChangedInspectionTaskDeviceID = notification.userInfo![InspectionTaskDeviceIDKey] as! String
        let inspectionTaskUploadingState = notification.userInfo![InspectionTaskUploadingStateKey] as! String
        let state: InspectionUploadingState = InspectionUploadingState(rawValue: inspectionTaskUploadingState)!
        
        if cell != nil {
            if cell!.inspectionDeviceID == stateChangedInspectionTaskDeviceID  {
                switch state {
                case .UploadingCompleted:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.inspectionUploadingQueueTableView.setEditing(true, animated: true)
                        
                        self.inspectionUploadingQueueTableView.beginUpdates()
                        self.inspectionUploadingQueueTableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
                        self.inspectionUploadingQueueTableView.endUpdates()
                        self.inspectionUploadingQueueTableView.setEditing(false, animated: true)
                    }
                    break
                    
                default:
                    dispatch_async(dispatch_get_main_queue()){
                        self.inspectionUploadingQueueTableView.beginUpdates()
                        cell!.bindData(WISInsepctionDataManager.sharedInstance().inspectionTasksUploadingQueue[0])
                        self.inspectionUploadingQueueTableView.endUpdates()
                    }
                    break
                }
            }
        }
    }
    
    func reloadTableView() -> Void {
        dispatch_async(dispatch_get_main_queue()) { 
            self.inspectionUploadingQueueTableView.reloadData()
        }
    }
    
    /// completion block executes before view will appear
    class func performPushToInspectionUploadingQueueViewController (superViewController:UIViewController, completion: (() -> Void)?) -> Void {
        
        let board = UIStoryboard.init(name: "InspectionUploadingQueue", bundle: NSBundle.mainBundle())
        let viewController = board.instantiateViewControllerWithIdentifier("InspectionUploadingQueueViewController") as! InspectionUploadingQueueViewController
        viewController.hidesBottomBarWhenPushed = true
        superViewController.navigationController?.pushViewController(viewController, animated: true)
        completion!()
    }
}

    
    // MARK: - UITableViewDataSource, UITableViewDelegate

extension InspectionUploadingQueueViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Number of sections in TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// Number of Rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WISInsepctionDataManager.sharedInstance().inspectionTasksUploadingQueue.count
    }
    
    /// Set height of header in section
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    /// Set height of row
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    /// Set Cells in section
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: InspectionUploadingQueueCell.self, indexPath: indexPath)
        cell.bindData(WISInsepctionDataManager.sharedInstance().inspectionTasksUploadingQueue[indexPath.row])
        cell.selectionStyle = .None
        return cell
    }
    
    /// Select Row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
