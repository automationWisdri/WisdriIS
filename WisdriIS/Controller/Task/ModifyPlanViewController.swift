//
//  ModifyPlanViewController.swift
//  WisdriIS
//
//  Created by 任韬 on 16/4/27.
//  Copyright © 2016年 Wisdri. All rights reserved.
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
    @IBOutlet weak var accessoryImageView: UIImageView!
    
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
    
    private let taskMediaCellID = "TaskMediaCell"
    
    // 导入页面的 Segue Identifier
    var segueIdentifier: String?
    private let pickUserSegueIdentifier = "pickUserForModifyPlan"
    
    // 获取已有的维保方案
    var wisPlan: WISMaintenancePlan?
    
    // 页面加载时获取 WISMaintenancePlan.participants
    // 获取 PickUser 页面返回的用户数组，用于 “参与人员” TextView 的显示
    var taskParticipants = [WISUser]()
    private var wisFileInfos = [WISFileInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for item : AnyObject in self.wisPlan!.imagesInfo.allKeys {
            self.wisFileInfos.append(self.wisPlan!.imagesInfo.objectForKey(item) as! WISFileInfo)
        }
        
        switch segueIdentifier! {
            
        case "modifyPlanOperation":
            title = "修改方案"
            
            taskPlanTextView.text = wisPlan?.planDescription
            
            taskParticipants = wisPlan!.participants.copy() as! [WISUser]
            for user in taskParticipants {
                print(user.userName)
            }
            
            estimateDatePicker.date = wisPlan!.estimatedEndingTime
            
            print(wisPlan?.estimatedEndingTime)
            break
            
        case "approveOperation":
            title = "同意方案"
            
            taskPlanTextView.text = wisPlan?.planDescription
            
            taskParticipants = wisPlan!.participants.copy() as! [WISUser]
            for user in taskParticipants {
                print(user.userName)
            }
            print(wisPlan!.estimatedEndingTime)
            estimateDatePicker.date = wisPlan!.estimatedEndingTime
            break
            
        case "recheckOperation":
            title = "复审方案"
            break
            
        default:
            break
        }
        
        
        view.backgroundColor = UIColor.yepBackgroundColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.userInteractionEnabled = true
        
        self.modifyPlanScrollView.delegate = self
        
        taskPlanLabel.text = NSLocalizedString("Task Plan")
        estimateDateLabel.text = NSLocalizedString("Estimate Time")
        relevantUserLabel.text = NSLocalizedString("Relevant User")
        
        navigationItem.rightBarButtonItem = postButton
        
        taskPlanTextView.textContainer.lineFragmentPadding = 0
        taskPlanTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        taskPlanTextView.delegate = self
        
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.hidden = false
        mediaCollectionViewHeightConstraint.constant = 80
        
        relevantUserTextView.textContainer.lineFragmentPadding = 0
        relevantUserTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        if taskParticipants.count == 0 {
            relevantUserTextView.text = ""
        }
        
        let tapToPickUser = UITapGestureRecognizer(target: self, action: #selector(ModifyPlanViewController.tapToPickUser(_:)))
        //        accessoryImageView.userInteractionEnabled = true
        //        accessoryImageView.addGestureRecognizer(tapImage)
        relevantUserView.userInteractionEnabled = true
        relevantUserView.addGestureRecognizer(tapToPickUser)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        relevantUserTextView.text = ""
        // 有问题，待修改
        switch taskParticipants.count {
        case 0:
            relevantUserTextView.text = ""
        default:
            for user in taskParticipants {
                if user == taskParticipants.last {
                    relevantUserTextView.text = relevantUserTextView.text + user.fullName
                } else {
                    relevantUserTextView.text = user.fullName + "， " + relevantUserTextView.text
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        
        SVProgressHUD.showWithStatus("正在提交")
        print(estimateDatePicker.date)
        switch self.segueIdentifier! {
            
        case "approveOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Approve, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: nil, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("提交成功")
                    // self.navigationController?.popViewControllerAnimated(true)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    errorCode(error)
                }
            }
            break
            
        case "recheckOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.ApplyForRecheck, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: nil, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("提交成功")
                    // self.navigationController?.popViewControllerAnimated(true)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    errorCode(error)
                }
            }
            break
            
        case "modifyPlanOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: "修改维保方案", operationType: MaintenanceTaskOperationType.Modify, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: nil, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.setDefaultMaskType(.None)
                    SVProgressHUD.showSuccessWithStatus("修改成功")
                    self.navigationController?.popViewControllerAnimated(true)
                    // self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    errorCode(error)
                }
            }
            break
            
        default:
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showErrorWithStatus("提交失败")
            break
        }
    }

    @objc private func tapToPickUser(sender: UITapGestureRecognizer) {
        
        performSegueWithIdentifier("pickUser", sender: nil)
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

}

// MARK: - UIScrollViewDelegate

extension ModifyPlanViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        taskPlanTextView.resignFirstResponder()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ModifyPlanViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return attachments.count
        print("Description 中有 \(wisFileInfos.count) 张图片")
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TaskMediaCell
        
        let transitionView = cell.imageView
        //        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, attachments: attachments, index: indexPath.item)
        //        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, attachments: attachments, index: indexPath.item)
    }
}