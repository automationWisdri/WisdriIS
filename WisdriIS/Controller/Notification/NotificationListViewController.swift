//
//  NotificationListViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD


class NotificationListViewController : BaseViewController {
    
    // var inspectionTasks = [WISInspectionTask]()
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    private let notificationListCellID = "NotificationListCell"
    // private let notificationDetailViewSegueID = "showNotificationDetail"
    
    var tableViewEditButton: UIBarButtonItem?
    var superViewController: UIViewController?
    
    var hasNoNotification: Bool = false {
        didSet {
            if hasNoNotification != oldValue {
                self.notificationTableView.tableFooterView = hasNoNotification ? noNotificationFooterView : UIView()
                self.navigationItem.rightBarButtonItem = hasNoNotification ? nil : tableViewEditButton
            }
        }
    }
    
    private var noNotificationFooterView: InfoView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        title = NSLocalizedString("Notification List")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.newPushNotificationArrived(_:)), name: OnLineNotificationReceivedNotification, object: nil)
        
        tableViewEditButton = UIBarButtonItem.init(title: NSLocalizedString("Edit", comment: ""), style: .Plain, target: self, action: #selector(self.toggleEditingMode(_:)))
        self.navigationItem.rightBarButtonItem = tableViewEditButton
        
        /// *** list setting
        notificationTableView.registerNib(UINib(nibName: notificationListCellID, bundle: nil), forCellReuseIdentifier: notificationListCellID)
        
        // notificationTableView.separatorColor = UIColor.wisCellSeparatorColor()
        // notificationTableView.separatorInset = WISConfig.ContactsCell.separatorInset
        notificationTableView.tableFooterView = UIView()
        noNotificationFooterView = InfoView(NSLocalizedString("No Notification", comment:""))
        
        // notificationTableView.mj_header = WISRefreshHeader(refreshingBlock: {[weak self] () -> Void in
        //     self?.refresh()
        //     })
        // self.refreshPage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTableViewInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OnLineNotificationReceivedNotification, object: nil)
    }
    
    func refreshPage(){
        notificationTableView.mj_header.beginRefreshing()
    }
    
    
    func refresh(){
        // do updating job
        
        notificationTableView.mj_header.endRefreshing()
    }
    
    func toggleEditingMode(sender: UITabBarItem) {
        if self.notificationTableView.editing {
            self.tableViewEditButton?.title = NSLocalizedString("Edit", comment: "")
            self.notificationTableView.setEditing(false, animated: true)
        } else {
            self.tableViewEditButton?.title = NSLocalizedString("Done", comment: "")
            self.notificationTableView.setEditing(true, animated: true)
        }
    }
    
    func newPushNotificationArrived(sender: NSNotification) -> Void {
        /** doesn't work
        let newRow: Int = Int(sender.object as! String)!
        let newNotification = WISPushNotificationDataManager.sharedInstance().pushNotifications[newRow]
        let indexPath = NSIndexPath(forRow: newRow, inSection: 0)
        let cell = getCell(self.notificationTableView, cell: NotificationListCell.self, indexPath: indexPath)
        cell.bindData(newNotification)
        
        self.notificationTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
         */
        
        self.updateTableViewInfo()
    }
    
    class func performPushToNotificationListView(superViewController:UIViewController) -> Void {
        let board = UIStoryboard.init(name: "NotificationList", bundle: NSBundle.mainBundle())
        let viewController = board.instantiateViewControllerWithIdentifier("NotificationListViewController") as! NotificationListViewController
        
        viewController.superViewController = superViewController
        viewController.hidesBottomBarWhenPushed = true
        superViewController.navigationController?.pushViewController(viewController, animated: true)
        // superViewController.tabBarController?.tabBar.hidden = true
    }
    
    private func updateTableViewInfo() {
        self.hasNoNotification = WISPushNotificationDataManager.sharedInstance().pushNotifications.isEmpty
        
        dispatch_async(dispatch_get_main_queue()){
            self.notificationTableView.reloadData()
        }
    }
}


// MARK: - Table view data source & delegate method

extension NotificationListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = WISPushNotificationDataManager.sharedInstance().pushNotifications.count
        return number
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return NotificationListCell.cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let notifications = WISPushNotificationDataManager.sharedInstance().pushNotifications
        
        guard notifications.count > 0 else {
            return UITableViewCell()
        }
        
        guard indexPath.row < notifications.count else {
            return getCell(tableView, cell: NotificationListCell.self, indexPath: NSIndexPath(forRow: notifications.count - 1, inSection: 0))
        }
        
        let cell = getCell(tableView, cell: NotificationListCell.self, indexPath: indexPath)
        cell.selectionStyle = .None
        cell.bindData(notifications[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            WISPushNotificationDataManager.sharedInstance().removePushNotificationByIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.hasNoNotification = WISPushNotificationDataManager.sharedInstance().pushNotifications.isEmpty
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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
  Delete the row from the data source
 tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
 } else if editingStyle == .Insert {
  Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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


