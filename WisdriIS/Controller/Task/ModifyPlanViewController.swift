//
//  ModifyPlanViewController.swift
//  WisdriIS
//
//  Created by Allen on 4/27/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

class ModifyPlanViewController: BaseViewController {

    @IBOutlet weak var taskPlanLabel: UILabel!
    @IBOutlet weak var taskPlanTextView: UITextView!
    
    @IBOutlet weak var estimateDateLabel: UILabel!
    @IBOutlet weak var estimateDatePicker: UIDatePicker!
    
    @IBOutlet weak var relevantUserView: UIView!
    @IBOutlet weak var relevantUserLabel: UILabel!
    @IBOutlet weak var relevantUserTextView: UITextView!
    
    @IBOutlet weak var taskPlanTopLine: HorizontalLineView!
    @IBOutlet weak var taskPlanBottomLine: HorizontalLineView!
    
    @IBOutlet weak var modifyPlanScrollView: UIScrollView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(ModifyPlanViewController.post(_:)))
        button.enabled = true
        return button
    }()
    
    private let infoAboutThisPlan = NSLocalizedString("Maintenance plan about this Task...", comment: "")
    
    private var isNeverInputMessage = false
    private var isDirty = false
    
    private let taskMediaCellID = "TaskMediaCell"
    
    // 导入页面的 Segue Identifier
    var segueIdentifier: String?
    // 导出页面的 Segue Identifier
    private let pickUserSegueIdentifier = "pickUserForModifyPlan"
    
    // 获取已有的维保方案
    var wisPlan: WISMaintenancePlan?
    
    // 页面加载时获取 WISMaintenancePlan.participants
    // 获取 PickUser 页面返回的用户数组，用于 “参与人员” TextView 的显示
    var taskParticipants = [WISUser]()
    // wisFileInfos 用于 CollcetionView 中图片等显示
    private var wisFileInfos = [WISFileInfo]()
    // imagesInfo 用于 DataMangaer 接口
    private var imagesInfo = [String : WISFileInfo]()
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, wisFileInfos: [WISFileInfo], index: Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make UI
        switch segueIdentifier! {
            
        case "approveOperation":
            title = NSLocalizedString("Approve Task")
            
        case "recheckOperation":
            title = NSLocalizedString("Recheck Task")
            
        case "continueOperation":
            title = NSLocalizedString("Continue Task")
            break
            
        default:
            break
        }
        
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.userInteractionEnabled = true
        
        taskPlanLabel.text = NSLocalizedString("Task Plan")
        estimateDateLabel.text = NSLocalizedString("Estimate Time")
        relevantUserLabel.text = NSLocalizedString("Relevant User")
        
        navigationItem.rightBarButtonItem = postButton
        
        taskPlanTextView.textContainer.lineFragmentPadding = 0
        taskPlanTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.contentInset.left = WISConfig.MediaCollection.leftEdgeInset
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.hidden = false
        mediaCollectionViewHeightConstraint.constant = 80
        
        relevantUserTextView.textContainer.lineFragmentPadding = 0
        relevantUserTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Bind Data
        bind()
        
    }
    
    private func bind() {
        
        guard let _ = wisPlan else {
            return
        }
        
        taskPlanTextView.text = wisPlan!.planDescription
        
        for item : AnyObject in self.wisPlan!.imagesInfo.allKeys {
            self.wisFileInfos.append(self.wisPlan!.imagesInfo.objectForKey(item) as! WISFileInfo)
            self.imagesInfo[item as! String] = (self.wisPlan!.imagesInfo.objectForKey(item) as! WISFileInfo)
        }
        
        relevantUserTextView.text = WISUserDefaults.getRelevantUserText(wisPlan!.participants)
        estimateDatePicker.date = wisPlan!.estimatedEndingTime
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        
        SVProgressHUD.showWithStatus(WISConfig.HUDString.commiting)
        switch self.segueIdentifier! {
            
        case "approveOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Approve, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: self.imagesInfo, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(WISConfig.HUDString.success)
                    // self.navigationController?.popViewControllerAnimated(true)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    WISConfig.errorCode(error)
                }
            }
            break
            
        case "recheckOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.ApplyForRecheck, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: self.imagesInfo, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(WISConfig.HUDString.success)
                    // self.navigationController?.popViewControllerAnimated(true)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    WISConfig.errorCode(error)
                }
            }
            break
            
        case "continueOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Continue, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: self.estimateDatePicker.date, maintenancePlanDescription: self.taskPlanTextView.text, maintenancePlanParticipants: self.taskParticipants, taskImageInfo: self.imagesInfo, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus(WISConfig.HUDString.success)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    WISConfig.errorCode(error)
                }
            }
            
        default:
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showErrorWithStatus(WISConfig.HUDString.failure)
            break
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        restoreTextViewPlaceHolder()
    }

    @objc private func tapToPickUser(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("pickUser", sender: nil)
    }

    private func restoreTextViewPlaceHolder() {
        taskPlanTextView.resignFirstResponder()
        if !isDirty && isNeverInputMessage {
            taskPlanTextView.text = infoAboutThisPlan
            taskPlanTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "pickUser" {
            let vc = segue.destinationViewController as! PickUserViewController
            vc.segueIdentifier = self.pickUserSegueIdentifier
            for wisUser in self.taskParticipants {
                vc.taskParticipantsUsername.append(wisUser.userName)
            }
        }
    }
    
    /* 该方法未使用，待完善
     * 目前维保方案文本的 TextView 高度限制死了
    private func calHeightOfPlanTextView(text text: String) -> CGFloat {
        
        let rect = text.boundingRectWithSize(CGSize(width: TaskPlanCell.planTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: WISConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        return ceil(rect.height)
    }
     */

}

// MARK: - UITextViewDelegate

extension ModifyPlanViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if !isDirty {
            textView.text = ""
        }
        
        isNeverInputMessage = false
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        isNeverInputMessage = NSString(string: textView.text).length == 0
        isDirty = NSString(string: textView.text).length > 0
    }
}

// MARK: - UIScrollViewDelegate

extension ModifyPlanViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        restoreTextViewPlaceHolder()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ModifyPlanViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wisFileInfos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell
        
        if wisFileInfos.count != 0 {
            cell.configureWithFileInfo(wisFileInfos[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    /* 暂不考虑在同意、复审页面查看大图
     *
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TaskMediaCell
        
        let transitionView = cell.imageView
        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, wisFileInfos: wisFileInfos, index: indexPath.item)
    }
     */
}