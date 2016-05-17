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

class SubmitPlanViewController: BaseViewController {

    // View elements
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
    
    // 获取已有的维保方案
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
            
            if !newValue && isNeverInputMessage {
                taskPlanTextView.text = infoAboutThisPlan
            }
            
            taskPlanTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    // 导入页面的 Segue Identifier
    var segueIdentifier: String?
    private let pickUserSegueIdentifier = "pickUserForSubmitPlan"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch segueIdentifier! {
            
        case "submitPlanOperation":
            title = NSLocalizedString("Submit Plan")
            isDirty = false
            break
            
        case "submitQuickPlanOperation":
            title = "快速方案"
            isDirty = false
            break
            
        case "modifyPlanOperation":
            title = "修改方案"

            taskPlanTextView.text = wisPlan?.planDescription
            
            isDirty = true

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
            
            isDirty = true
            
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
        
        let tapToPickUser = UITapGestureRecognizer(target: self, action: #selector(SubmitPlanViewController.tapToPickUser(_:)))
        //        accessoryImageView.userInteractionEnabled = true
        //        accessoryImageView.addGestureRecognizer(tapImage)
        relevantUserView.userInteractionEnabled = true
        relevantUserView.addGestureRecognizer(tapToPickUser)
        
//        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(SubmitPlanViewController.singleTapped(_:)))
//        self.view.addGestureRecognizer(singleTap)

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
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }
    
    @objc private func post(sender: UIBarButtonItem) {
        SVProgressHUD.showWithStatus("正在提交")
        print(estimateDatePicker.date)
        // 上传图片
        WISDataManager.sharedInstance().storeImageOfMaintenanceTaskWithTaskID(nil, images: imagesDictionary, uploadProgressIndicator: { progress in
            NSLog("Upload progress is %f", progress.fractionCompleted)
            }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                if completedWithNoError {
                    // 图片上传成功，提交维保方案
                    let images: Array<WISFileInfo> = data as! Array<WISFileInfo>
                    
                    for image in images {
                        self.taskImageInfo[image.fileName] = image
                    }
        
                    switch self.segueIdentifier! {
             /*
        case "approveOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.Approve, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: nil, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.showSuccessWithStatus("提交成功")
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            }
            break
            
        case "recheckOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: nil, operationType: MaintenanceTaskOperationType.ApplyForRecheck, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: nil, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.showSuccessWithStatus("提交成功")
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            }
            break
 
        case "modifyPlanOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: "修改维保方案", operationType: MaintenanceTaskOperationType.Modify, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: estimateDatePicker.date, maintenancePlanDescription: taskPlanTextView.text, maintenancePlanParticipants: taskParticipants, taskImageInfo: nil, taskRating: nil) { (completedWithNoError, error) in
                if completedWithNoError {
                    
                    SVProgressHUD.showSuccessWithStatus("修改成功")
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    errorCode(error)
                }
            }
            break
            */
                    case "submitPlanOperation":
                        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: "维保方案", operationType: MaintenanceTaskOperationType.SubmitMaintenancePlan, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: self.estimateDatePicker.date, maintenancePlanDescription: self.taskPlanTextView.text, maintenancePlanParticipants: self.taskParticipants, taskImageInfo: self.taskImageInfo, taskRating: nil) { (completedWithNoError, error) in
                            if completedWithNoError {
                                SVProgressHUD.setDefaultMaskType(.None)
                                SVProgressHUD.showSuccessWithStatus("提交成功")
                                self.navigationController?.popViewControllerAnimated(true)
                        
                            } else {
                                errorCode(error)
                            }
                        }
                        break
            
                    case "submitQuickPlanOperation":
                        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: "快速维保方案", operationType: MaintenanceTaskOperationType.StartFastProcedure, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: self.estimateDatePicker.date, maintenancePlanDescription: self.taskPlanTextView.text, maintenancePlanParticipants: self.taskParticipants, taskImageInfo: self.taskImageInfo, taskRating: nil) { (completedWithNoError, error) in
                            if completedWithNoError {
                                SVProgressHUD.setDefaultMaskType(.None)
                                SVProgressHUD.showSuccessWithStatus("提交成功")
                                self.navigationController?.popViewControllerAnimated(true)
                        
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
                    
                } else {
                    errorCode(error)
                }
            })
    
    
    }
    
    @objc private func tapToPickUser(sender: UITapGestureRecognizer) {
        
        performSegueWithIdentifier("pickUser", sender: nil)
    }
    
    func singleTapped(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
                    photoFileName = "task_image_" + String(image.hash)
                    self?.imagesDictionary[photoFileName!] = image
                }
            }
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
        
        isDirty = NSString(string: textView.text).length > 0
    }
}

// MARK: - UIScrollViewDelegate

extension SubmitPlanViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        taskPlanTextView.resignFirstResponder()
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
                    
                    if mediaImages.count <= 3 {
                        mediaImages.append(image)
                    }
                }
                
            default:
                break
            }
        }
        
        
        //        let imageName = imageURL.path!.lastPathComponent
        //        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        //        let localPath = documentDirectory.stringByAppendingPathComponent(imageName)
        //
        //        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //        let data = UIImagePNGRepresentation(image)
        //        data!.writeToFile(localPath, atomically: true)
        //
        //        let imageData = NSData(contentsOfFile: localPath)!
        //        let photoURL = NSURL(fileURLWithPath: localPath)
        //        let imageWithData = UIImage(data: imageData)!
        
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
        case 0:
            return 1
        case 1:
            return mediaImages.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaAddCellID, forIndexPath: indexPath) as! TaskMediaAddCell
            return cell
            
        case 1:
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
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            
        case 0:
            
            taskPlanTextView.resignFirstResponder()
            
            if mediaImages.count == 4 {
                YepAlert.alertSorry(message: NSLocalizedString("Task can only has 4 photos.", comment: ""), inViewController: self)
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
            
        case 1:
            mediaImages.removeAtIndex(indexPath.item)
            //            if !imageAssets.isEmpty {
            //                imageAssets.removeAtIndex(indexPath.item)
            //            }
            collectionView.deleteItemsAtIndexPaths([indexPath])
            
        default:
            break
        }
    }
}