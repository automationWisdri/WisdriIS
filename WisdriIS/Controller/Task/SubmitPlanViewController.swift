//
//  SubmitPlanViewController.swift
//  WisdriIS
//
//  Created by Allen on 3/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import SVProgressHUD
import Proposer

public let MaintenancePlanUploadingNotification = "MaintenancePlanUploadingNotification"

class SubmitPlanViewController: BaseViewController {

    // View elements
    @IBOutlet weak var taskPlanView: UIView!
    @IBOutlet weak var taskPlanLabel: UILabel!
    @IBOutlet weak var taskPlanTextView: UITextView!

    @IBOutlet weak var estimateDateView: UIView!
    @IBOutlet weak var estimateDateLabel: UILabel!
    @IBOutlet weak var estimateDatePicker: UIDatePicker!

    @IBOutlet weak var relevantUserView: UIView!
    @IBOutlet weak var relevantUserLabel: UILabel!
    @IBOutlet weak var relevantUserTextView: UITextView!
    @IBOutlet weak var accessoryImageView: UIImageView!

    @IBOutlet weak var taskPlanTopLine: HorizontalLineView!
    @IBOutlet weak var taskPlanBottomLine: HorizontalLineView!
    
    @IBOutlet weak var submitPlanScrollView: UIScrollView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(SubmitPlanViewController.post(_:)))
        button.enabled = false
        return button
    }()
    
    // 选取照片 Controller
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    private var imageAssets: [PHAsset] = []
    
    // 方案相关的图片
    private var mediaImages = [UIImage]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.mediaCollectionView.reloadData()
            }
        }
    }
    
    private let taskMediaAddCellID = "TaskMediaAddCell"
    private let taskMediaCellID = "TaskMediaCell"
    
    // 当前提交方案对应的任务编号
    private var taskID: String?
    // 获取已有的最新一条维保方案
    var wisPlan: WISMaintenancePlan?
    // 获取 PickUser 页面返回的用户数组，用于 “参与人员” TextView 的显示
    var taskParticipants = [WISUser]()
    
    private var imagesDictionary = Dictionary<String, UIImage>()
    private var taskImageInfo = Dictionary<String, WISFileInfo>()
    
    // TextView related
    private let infoAboutThisPlan = NSLocalizedString("Maintenance plan about this Task...", comment: "")
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            postButton.enabled = newValue
            
            if !newValue && isNeverInputMessage && !taskPlanTextView.isFirstResponder() {
                taskPlanTextView.text = infoAboutThisPlan
            }
            
            taskPlanTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    // 导入页面的 Segue Identifier
    var segueIdentifier: String?
    // 导出页面的 Segue Identifier
    private let pickUserSegueIdentifier = "pickUserForSubmitPlan"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskID = currentTask!.taskID
        
        switch segueIdentifier! {
            
        case "submitPlanOperation":
            title = NSLocalizedString("Submit Plan")
            isDirty = false
            break
            
        case "submitQuickPlanOperation":
            title = NSLocalizedString("Quick Run")
            isDirty = false
            break
            
        case "modifyPlanOperation":
            title = NSLocalizedString("Modify")
            isDirty = true
            bind()
            break
            
        default:
            break
        }
        
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.userInteractionEnabled = true
        
        self.submitPlanScrollView.delegate = self
        
        taskPlanLabel.text = NSLocalizedString("Task Plan")
        estimateDateLabel.text = NSLocalizedString("Estimate Time")
        relevantUserLabel.text = NSLocalizedString("Relevant User")
        
        navigationItem.rightBarButtonItem = postButton
        
        taskPlanTextView.textContainer.lineFragmentPadding = 0
        taskPlanTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskPlanTextView.delegate = self
        
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.registerNib(UINib(nibName: taskMediaAddCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaAddCellID)
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.contentInset.left = 20
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.hidden = false
        mediaCollectionViewHeightConstraint.constant = 80
        
        relevantUserTextView.textContainer.lineFragmentPadding = 0
        relevantUserTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let tapToPickUser = UITapGestureRecognizer(target: self, action: #selector(SubmitPlanViewController.tapToPickUser(_:)))

        relevantUserView.userInteractionEnabled = true
        relevantUserView.addGestureRecognizer(tapToPickUser)

    }
    
    private func bind() {
        
        guard let _ = wisPlan else {
            return
        }
        
        taskPlanTextView.text = wisPlan!.planDescription
//        relevantUserTextView.text = WISUserDefaults.getRelevantUserText(wisPlan!.participants)
        estimateDatePicker.date = wisPlan!.estimatedEndingTime
        
        for participant in wisPlan!.participants {
            self.taskParticipants.append(participant as! WISUser)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 用于显示 PickUser 页面返回后，获取的参与人员姓名
        // 或用于显示修改维保方案时，获取已有方案的参与人员姓名
        relevantUserTextView.text = WISUserDefaults.getRelevantUserText(taskParticipants)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        restoreTextViewPlaceHolder()
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        
        self.taskPlanTextView.resignFirstResponder()
        self.taskPlanView.userInteractionEnabled = false
        self.relevantUserView.userInteractionEnabled = false
        self.estimateDateView.userInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        if mediaImages.count > 0 {
            // 上传图片，发送正在上传的通知
            uploadingPlanDictionary[taskID!] = NSProgress()
            let notification = NSNotification(name: MaintenancePlanUploadingNotification, object: UploadingState.UploadingStart.rawValue)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        
        SVProgressHUD.setDefaultMaskType(.None)
        SVProgressHUD.showWithStatus(WISConfig.HUDString.committing)
        self.navigationController?.popViewControllerAnimated(true)
        
        WISDataManager.sharedInstance().storeImageOfMaintenanceTaskWithTaskID(nil, images: imagesDictionary, uploadProgressIndicator: { progress in
            if self.mediaImages.count > 0 {
                NSLog("Task \(self.taskID!)'s plan is uploading, progress is %.2f", progress.fractionCompleted)
                // 发送上传进度的通知
                uploadingPlanDictionary[self.taskID!] = progress
                let notification = NSNotification(name: MaintenancePlanUploadingNotification, object: UploadingState.UploadingPending.rawValue)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
            }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                if completedWithNoError {
                    // 图片上传成功，获取图片信息，并提交维保方案
                    let images: Array<WISFileInfo> = data as! Array<WISFileInfo>
                    
                    for image in images {
                        self.taskImageInfo[image.fileName] = image
                    }
        
                    switch self.segueIdentifier! {

                    case "modifyPlanOperation":
                        
                        for item: AnyObject in self.wisPlan!.imagesInfo.allKeys {
                            self.taskImageInfo[item as! String] = (self.wisPlan!.imagesInfo.valueForKey(item as! String) as! WISFileInfo)
                        }
                        
                        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Modify, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: self.estimateDatePicker.date, maintenancePlanDescription: self.taskPlanTextView.text, maintenancePlanParticipants: self.taskParticipants, taskImageInfo: self.taskImageInfo, taskRating: nil) { (completedWithNoError, error) in

                            self.submitPlanOperationCompletion(completedWithNoError, error: error)
                        }
 
                    case "submitPlanOperation":
                        
                        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.SubmitMaintenancePlan, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: self.estimateDatePicker.date, maintenancePlanDescription: self.taskPlanTextView.text, maintenancePlanParticipants: self.taskParticipants, taskImageInfo: self.taskImageInfo, taskRating: nil) { (completedWithNoError, error) in

                            self.submitPlanOperationCompletion(completedWithNoError, error: error)
                        }
                        break
            
                    case "submitQuickPlanOperation":
                        
                        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.StartFastProcedure, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: self.estimateDatePicker.date, maintenancePlanDescription: self.taskPlanTextView.text, maintenancePlanParticipants: self.taskParticipants, taskImageInfo: self.taskImageInfo, taskRating: nil) { (completedWithNoError, error) in

                            self.submitPlanOperationCompletion(completedWithNoError, error: error)
                        }
                        
                    default:
                        SVProgressHUD.setDefaultMaskType(.None)
                        SVProgressHUD.showErrorWithStatus(WISConfig.HUDString.failure)
                        break
                    }
                    
                } else {
                    if self.mediaImages.count > 0 {
                        // 发送上传结束的通知
                        uploadingPlanDictionary.removeValueForKey(self.taskID!)
                        let notification = NSNotification(name: MaintenancePlanUploadingNotification, object: UploadingState.UploadingCompleted.rawValue)
                        NSNotificationCenter.defaultCenter().postNotification(notification)
                    }
                    WISConfig.errorCode(error)
                }
            })
    
    
    }
    
    private func submitPlanOperationCompletion(completedWithNoError: Bool, error: NSError?) {
        if mediaImages.count > 0 {
            // 发送上传结束的通知
            uploadingPlanDictionary.removeValueForKey(taskID!)
            let notification = NSNotification(name: MaintenancePlanUploadingNotification, object: UploadingState.UploadingCompleted.rawValue)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        if completedWithNoError {
            SVProgressHUD.setDefaultMaskType(.None)
            SVProgressHUD.showSuccessWithStatus("方案提交成功")
        } else {
            WISConfig.errorCode(error!)
        }
    }
    
    @objc private func tapToPickUser(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("pickUser", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "pickUser" {
            let vc = segue.destinationViewController as! PickUserViewController
            vc.segueIdentifier = self.pickUserSegueIdentifier
            for wisUser in self.taskParticipants {
                vc.taskParticipantsUsername.append(wisUser.userName)
            }
        }
        
        if segue.identifier == "showPickPhotos" {
            
            let vc = segue.destinationViewController as! PickPhotosViewController
            var photoFileName: String?
            
            vc.pickedImageSet = Set(imageAssets)
            vc.imageLimit = mediaImages.count
            vc.completion = { [weak self] images, imageAssets in
                
                for image in images {
                    self?.mediaImages.append(image)
                    photoFileName = "plan_image_" + String(image.hash)
                    self?.imagesDictionary[photoFileName!] = image
                }
            }
        }
    }
    
    private func restoreTextViewPlaceHolder() {
        taskPlanTextView.resignFirstResponder()
        if !isDirty && isNeverInputMessage {
            taskPlanTextView.text = infoAboutThisPlan
            taskPlanTextView.textColor = UIColor.lightGrayColor()
        }
    }
}

// MARK: - UITextViewDelegate

extension SubmitPlanViewController: UITextViewDelegate {
    
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

extension SubmitPlanViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        restoreTextViewPlaceHolder()
    }
    
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension SubmitPlanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            switch mediaType {
                
            case kUTTypeImage as! String:
                
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    //                    let imageURL = info[UIImagePickerControllerReferenceURL] as? String
                    
                    if mediaImages.count <= 5 {
                        mediaImages.append(image)
                    }
                }
                
            default:
                break
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SubmitPlanViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 1:
            return 1
        case 0:
            return mediaImages.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaAddCellID, forIndexPath: indexPath) as! TaskMediaAddCell
            return cell
            
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell
            
            let image = mediaImages[indexPath.item]
            
            cell.configureWithImage(image)
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if mediaImages.count == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            
        case 1:
            
            taskPlanTextView.resignFirstResponder()
            
            if mediaImages.count == 6 {
                WISAlert.alertSorry(message: NSLocalizedString("Plan can only has 6 photos.", comment: ""), inViewController: self)
                return
            }
            
            let pickAlertController = UIAlertController(title: NSLocalizedString("Choose Source", comment: ""), message: nil, preferredStyle: .ActionSheet)
            
            let cameraAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .Default) { action -> Void in
                
                proposeToAccess(.Camera, agreed: { [weak self] in
                    
                    guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
                        self?.alertCanNotOpenCamera()
                        return
                    }
                    
                    if let strongSelf = self {
                        strongSelf.imagePicker.sourceType = .Camera
                        strongSelf.presentViewController(strongSelf.imagePicker, animated: true, completion: nil)
                    }
                    
                    }, rejected: { [weak self] in
                        self?.alertCanNotOpenCamera()
                    })
            }
            
            pickAlertController.addAction(cameraAction)
            
            let albumAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Albums", comment: ""), style: .Default) { [weak self] action -> Void in
                
                proposeToAccess(.Photos, agreed: { [weak self] in
                    self?.performSegueWithIdentifier("showPickPhotos", sender: nil)
                    
                    }, rejected: { [weak self] in
                        self?.alertCanNotAccessCameraRoll()
                    })
            }
            
            pickAlertController.addAction(albumAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { action -> Void in
                
            }
            
            pickAlertController.addAction(cancelAction)
            
            self.presentViewController(pickAlertController, animated: true, completion: nil)
            
        case 0:
            
            let imageToRemove = mediaImages[indexPath.item]
            let photoFileName = "plan_image_" + String(imageToRemove.hash)
            imagesDictionary.removeValueForKey(photoFileName)
            
            mediaImages.removeAtIndex(indexPath.item)
            collectionView.deleteItemsAtIndexPaths([indexPath])
            
        default:
            break
        }
    }
}