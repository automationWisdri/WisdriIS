//
//  NewTaskViewController.swift
//  WisdriIS
//
//  Created by Allen on 15/9/29.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import Proposer
import SVProgressHUD

public let NewTaskSubmittedSuccessfullyNotification = "NewTaskSubmittedSuccessfullyNotification"
public let MaintenanceTaskUploadingNotification = "MaintenanceTaskUploadingNotification"

class NewTaskViewController: BaseViewController {

    /// 用户默认所属的工艺段
    var preparedSegment: Segment?
    
    @IBOutlet private weak var taskWhiteBGView: UIView!
    
    @IBOutlet private weak var messageTextView: UITextView!

    @IBOutlet private weak var mediaCollectionView: UICollectionView!
    @IBOutlet private weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var channelView: UIView!
    @IBOutlet private weak var channelViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var channelViewTopLineView: HorizontalLineView!
    @IBOutlet private weak var channelViewBottomLineView: HorizontalLineView!
    
    @IBOutlet private weak var channelLabel: UILabel!
    @IBOutlet private weak var choosePromptLabel: UILabel!
    
    @IBOutlet private weak var pickedSegmentLabel: UILabel!
    
    @IBOutlet private weak var segmentPickerView: UIPickerView!

    private let infoAboutThisTask = NSLocalizedString("Info about this Task...", comment: "")

    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            if !newValue && isNeverInputMessage && !messageTextView.isFirstResponder() {
                messageTextView.text = infoAboutThisTask
            }

            messageTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
        didSet {
            if pickedSegment != nil {
                if pickedSegment?.id != "0" {
                    postButton.enabled = self.isDirty
                }
            }
        }
    }
    
    var prefersHideStatuseBar = false

    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(NewTaskViewController.post(_:)))
            button.enabled = false
        return button
    }()

    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    private var imageAssets: [PHAsset] = []
    
    /// 任务图片，显示于 Media Collection View
    private var mediaImages = [UIImage]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.mediaCollectionView.reloadData()
            }
        }
    }
    
    /// DataManager 查询任务相关图片获得的返回值
    private var imagesDictionary = Dictionary<String, UIImage>()
    /// DataManager 新建任务时的图片信息
    private var applicationFileInfo = Dictionary<String, WISFileInfo>()
    
    private let taskMediaAddCellID = "TaskMediaAddCell"
    private let taskMediaCellID = "TaskMediaCell"
    
    //let max = Int(INT16_MAX)
    private var segments = [Segment]()
    
    private var pickedSegment: Segment? {
        willSet {
            pickedSegmentLabel.text = newValue?.name
            choosePromptLabel.hidden = (newValue != nil)
        }
        didSet {
            if pickedSegment != nil {
                if pickedSegment?.id != "0" {
                    postButton.enabled = self.isDirty
                }
            } else {
                postButton.enabled = false
            }
        }
    }

    deinit {
        print("NewTask deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("New Task", comment: "")
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        navigationItem.rightBarButtonItem = postButton

        let cancleButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .Plain, target: self, action: #selector(NewTaskViewController.cancel(_:)))

        navigationItem.leftBarButtonItem = cancleButton
        self.view.userInteractionEnabled = true
        view.sendSubviewToBack(taskWhiteBGView)
        
        isDirty = false

//        print(messageTextView.text)
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTextView.delegate = self
//        messageTextView.becomeFirstResponder()
        
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.registerNib(UINib(nibName: taskMediaAddCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaAddCellID)
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.contentInset.left = WISConfig.MediaCollection.leftEdgeInset
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        
        // 获取在登录时查询到的用户所属工艺段
        segments = userSegmentList
        
        // 如果系统默认的工艺段（例如：测试工艺段），在用户所属的工艺段列表中，自动为该任务选择工艺段
        if let segment = preparedSegment, _ = segments.indexOf(segment) {
            pickedSegment = preparedSegment
        }
        
        channelLabel.text = NSLocalizedString("Channel:", comment: "")
        choosePromptLabel.text = NSLocalizedString("Choose...", comment: "")
        
        channelViewTopConstraint.constant = 30
        
        segmentPickerView.dataSource = self
        segmentPickerView.delegate = self
        
        segmentPickerView.alpha = 0
        
        let hasSegment = (pickedSegment != nil)
        pickedSegmentLabel.alpha = hasSegment ? 1 : 0
        
        channelView.backgroundColor = UIColor.whiteColor()
        channelView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewTaskViewController.showSegmentPickerView(_:)))
        channelView.addGestureRecognizer(tap)
        
        mediaCollectionView.hidden = false
        mediaCollectionViewHeightConstraint.constant = 80
    }

    override func prefersStatusBarHidden() -> Bool {
        return self.prefersHideStatuseBar
    }
    
    // MARK: UI

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showPickPhotos" {
            
            let vc = segue.destinationViewController as! PickPhotosViewController
            var photoFileName: String?
            
            vc.pickedImageSet = Set(imageAssets)
            vc.imageLimit = mediaImages.count
            vc.completion = { [weak self] images, imageAssets in
                
                for image in images {
                    self?.mediaImages.append(image)
                    
                    photoFileName = "task_image_" + String(image.hashValue)
                    self?.imagesDictionary[photoFileName!] = image
                }
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func showSegmentPickerView(tap: UITapGestureRecognizer) {
        
        // 初次 show，预先 selectRow

        self.messageTextView.endEditing(true)
        
        if pickedSegment == nil {
            if !segments.isEmpty {
                //let centerRow = max / 2
                //let selectedRow = centerRow
                let selectedRow = 0
                segmentPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                
                pickedSegment = segments[selectedRow % segments.count]
            }
            
        } else {
            if let segment = preparedSegment, let index = segments.indexOf(segment) {
            
                //var selectedRow = max / 2
                //selectedRow = selectedRow - selectedRow % segments.count + index
                let selectedRow = index

                segmentPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                pickedSegment = segments[selectedRow % segments.count]
            }
            
            preparedSegment = nil // 再 show 就不需要 selectRow 了
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in
            
            self?.channelView.backgroundColor = UIColor.clearColor()
            self?.channelViewTopLineView.alpha = 0
            self?.channelViewBottomLineView.alpha = 0
            self?.choosePromptLabel.alpha = 0

            self?.pickedSegmentLabel.alpha = 0
            
            self?.segmentPickerView.alpha = 1
            
            self?.channelViewTopConstraint.constant = 108
            self?.view.layoutIfNeeded()
            
        }, completion: { [weak self] _ in
            self?.channelView.userInteractionEnabled = false
        })
    }

    private func hideSegmentPickerView() {
        
        if pickedSegment == segmentPlaceholder {
            pickedSegment = nil
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in
            
            self?.channelView.backgroundColor = UIColor.whiteColor()
            self?.channelViewTopLineView.alpha = 1
            self?.channelViewBottomLineView.alpha = 1
            self?.choosePromptLabel.alpha = 1
            
            if let _ = self?.pickedSegment {
                self?.pickedSegmentLabel.alpha = 1
                print(self?.pickedSegmentLabel.text)
            }
            
            self?.segmentPickerView.alpha = 0
            
            self?.channelViewTopConstraint.constant = 30
            self?.view.layoutIfNeeded()
            
        }, completion: { [weak self] _ in
            self?.channelView.userInteractionEnabled = true
        })
    }

    @objc private func cancel(sender: UIBarButtonItem) {
        
        messageTextView.resignFirstResponder()

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func post(sender: UIBarButtonItem) {
        
        // 任务描述字段的长度控制
        let messageLength = (messageTextView.text as NSString).length
        
        guard messageLength <= WISConfig.maxTaskTextLength else {
            let message = String(format: NSLocalizedString("Info is too long!\nUp to %d letters.", comment: ""), WISConfig.maxTaskTextLength)
            WISAlert.alertSorry(message: message, inViewController: self)
            return
        }
            
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let uploadingTaskKey = String(uploadingTaskDictionary.count + 1)
        uploadingTaskDictionary[uploadingTaskKey] = NSProgress()
        
        let notification = NSNotification(name: MaintenanceTaskUploadingNotification, object: UploadingState.UploadingStart.rawValue)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        WISDataManager.sharedInstance().storeImageOfMaintenanceTaskWithTaskID(nil, images: imagesDictionary, uploadProgressIndicator: { progress in
            NSLog("Upload progress is %.2f", progress.fractionCompleted)

            uploadingTaskDictionary[uploadingTaskKey] = progress
            let notification = NSNotification(name: MaintenanceTaskUploadingNotification, object: UploadingState.UploadingPending.rawValue)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
            }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                if completedWithNoError {
                    // 图片上传成功，新建任务单
                    let images: [WISFileInfo] = data as! [WISFileInfo]
                    
                    for image in images {
                        self.applicationFileInfo[image.fileName] = image
                    }
                    
                    WISDataManager.sharedInstance().applyNewMaintenanceTaskWithApplicationContent(self.messageTextView.text, processSegmentID: self.pickedSegment?.id, applicationImageInfo: self.applicationFileInfo, completionHandler: { (completedWithNoError, error) -> Void in
                        
                        uploadingTaskDictionary.removeValueForKey(uploadingTaskKey)
                        let notification = NSNotification(name: MaintenanceTaskUploadingNotification, object: UploadingState.UploadingCompleted.rawValue)
                        NSNotificationCenter.defaultCenter().postNotification(notification)
                        
                        if completedWithNoError {

                            SVProgressHUD.setDefaultMaskType(.None)
                            SVProgressHUD.showSuccessWithStatus(NSLocalizedString("New maintenance task submitted successfully", comment: ""))
                            NSNotificationCenter.defaultCenter().postNotificationName(NewTaskSubmittedSuccessfullyNotification, object: nil, userInfo: nil)
                            
                        } else {
                            WISConfig.errorCode(error)
                        }
                    })
                    
                } else {
                    uploadingTaskDictionary.removeValueForKey(uploadingTaskKey)
                    let notification = NSNotification(name: MaintenanceTaskUploadingNotification, object: UploadingState.UploadingCompleted.rawValue)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    WISConfig.errorCode(error)
                }
        })
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        hideSegmentPickerView()
        restoreTextViewPlaceHolder()
    }
    
    private func restoreTextViewPlaceHolder() {
        messageTextView.resignFirstResponder()
        
        if !isDirty && isNeverInputMessage {
            messageTextView.text = infoAboutThisTask
            messageTextView.textColor = UIColor.lightGrayColor()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension NewTaskViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return mediaImages.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell
            let image = mediaImages[indexPath.item]
            cell.configureWithImage(image)
            return cell

        case 1:
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaAddCellID, forIndexPath: indexPath) as! TaskMediaAddCell
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
            
        case 0:
            
            mediaImages.removeAtIndex(indexPath.item)
            collectionView.deleteItemsAtIndexPaths([indexPath])
            
        case 1:

            messageTextView.resignFirstResponder()
            
            if mediaImages.count == 6 {
                WISAlert.alertSorry(message: NSLocalizedString("Task can only has 6 photos.", comment: ""), inViewController: self)
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
            
        default:
            break
        }
    }
}

// MARK: - UITextViewDelegate

extension NewTaskViewController: UITextViewDelegate {

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
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        hideSegmentPickerView()
    }
    
}

// MARK: - UIScrollViewDelegate

extension NewTaskViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {

        restoreTextViewPlaceHolder()
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension NewTaskViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return segments.isEmpty ? 0 : 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return segments.count
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let skill = segments[row % segments.count]
        
        if let view = view as? TaskSectionPickerItemView {
            view.configureWithString(skill.name)
            return view
        } else {
            let view = TaskSectionPickerItemView()
            view.configureWithString(skill.name)
            return view
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        pickedSegment = segments[row % segments.count]    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension NewTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            switch mediaType {
                
            case kUTTypeImage as! String:
                
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    if mediaImages.count <= 3 {
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
