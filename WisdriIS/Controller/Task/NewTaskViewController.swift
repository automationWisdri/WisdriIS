//
//  NewTaskViewController.swift
//  WisdriIS
//
//  Created by Allen on 15/9/29.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import Photos
import Proposer
import RealmSwift
import Kingfisher
import MapKit
import SVProgressHUD

let generalSkill = Segment(id: "0", name: NSLocalizedString("Choose...", comment: ""))

//struct FeedVoice {
//
//    let fileURL: NSURL
//    let sampleValuesCount: Int
//    let limitedSampleValues: [CGFloat]
//}

struct Segment: Hashable {
    
    var id: String
    var name: String
    
    var hashValue: Int {
        return id.hashValue
    }

}

func ==(lhs: Segment, rhs: Segment) -> Bool {
    return lhs.id == rhs.id
}

class NewTaskViewController: BaseViewController {

    var preparedSkill: Segment?

    weak var feedsViewController: TaskListViewController?
    var getFeedsViewController: (() -> TaskListViewController?)?


    @IBOutlet private weak var feedWhiteBGView: UIView!
    
    @IBOutlet private weak var messageTextView: UITextView!

    @IBOutlet private weak var mediaCollectionView: UICollectionView!
    @IBOutlet private weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var channelView: UIView!
    @IBOutlet private weak var channelViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var channelViewTopLineView: HorizontalLineView!
    @IBOutlet private weak var channelViewBottomLineView: HorizontalLineView!
    
    @IBOutlet private weak var channelLabel: UILabel!
    @IBOutlet private weak var choosePromptLabel: UILabel!
    
//    @IBOutlet private weak var pickedSkillBubbleImageView: UIImageView!
    @IBOutlet private weak var pickedSkillLabel: UILabel!
    
    @IBOutlet private weak var skillPickerView: UIPickerView!

//    private lazy var socialWorkHalfMaskImageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(named: "social_media_image_mask"))
//        return imageView
//    }()
//
//    private lazy var socialWorkFullMaskImageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(named: "social_media_image_mask_full"))
//        return imageView
//    }()

    private let infoAboutThisFeed = NSLocalizedString("Info about this Task...", comment: "")

    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            postButton.enabled = newValue

            if !newValue && isNeverInputMessage {
                messageTextView.text = infoAboutThisFeed
            }

            messageTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }

    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(NewTaskViewController.post(_:)))
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
    
    // 任务相关的图片
    private var mediaImages = [UIImage]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.mediaCollectionView.reloadData()
            }
        }
    }
    
    // DataManager 查询任务相关图片获得的返回值
    private var imagesDictionary = Dictionary<String, UIImage>()
//    private var imagesArray = Array<WISFileInfo>()
    private var applicationFileInfo = Dictionary<String, WISFileInfo>()

    enum UploadState {
        case Ready
        case Uploading
        case Failed(message: String)
        case Success
    }
    
    var uploadState: UploadState = .Ready {
        willSet {
            switch newValue {

            case .Ready:
                break

            case .Uploading:
                postButton.enabled = false
                messageTextView.resignFirstResponder()
//                YepHUD.showActivityIndicator()

//            case .Failed(let message):
//                YepHUD.hideActivityIndicator()
//                postButton.enabled = true

//                if presentingViewController != nil {
//                    YepAlert.alertSorry(message: message, inViewController: self)
//                } else {
//                    feedsViewController?.handleUploadingErrorMessage(message)
//                }

            case .Success:
//                YepHUD.hideActivityIndicator()
                messageTextView.text = nil
            default:
                break
            }
        }
    }
    
    private let taskMediaAddCellID = "TaskMediaAddCell"
    private let taskMediaCellID = "TaskMediaCell"
    
    //let max = Int(INT16_MAX)
    private var skills = [Segment]()
    
    private var pickedSkill: Segment? {
        willSet {
            pickedSkillLabel.text = newValue?.name
            choosePromptLabel.hidden = (newValue != nil)
        }
    }
    
    func setupSegment() {
        WISDataManager.sharedInstance().updateProcessSegmentWithCompletionHandler({ (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
            self.skills.insert(generalSkill, atIndex: 0)
            if completedWithNoError {
                let segments: Dictionary = updatedData as! Dictionary<String, String>
                for (id, name) in segments {
                    let skill = Segment(id: id, name: name)
                    self.skills.append(skill)
                }
//                self.skillPickerView.reloadInputViews()
            }
        })

    }

    deinit {
        print("NewTask deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("New Task", comment: "")
        view.backgroundColor = UIColor.yepBackgroundColor()
        
        navigationItem.rightBarButtonItem = postButton

        let cancleButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .Plain, target: self, action: #selector(NewTaskViewController.cancel(_:)))

        navigationItem.leftBarButtonItem = cancleButton
        self.view.userInteractionEnabled = true
        view.sendSubviewToBack(feedWhiteBGView)

        feedsViewController = getFeedsViewController?()
        print("feedsViewController: \(feedsViewController)")
        
        isDirty = false

        print(messageTextView.text)
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTextView.delegate = self
//        messageTextView.becomeFirstResponder()
        
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.registerNib(UINib(nibName: taskMediaAddCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaAddCellID)
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        
        // pick skill
        skills = userSegmentList
        
        // 只有自己也有，才使用准备的
        if let skill = preparedSkill, _ = skills.indexOf(skill) {
            pickedSkill = preparedSkill
        }
        
        channelLabel.text = NSLocalizedString("Channel:", comment: "")
        choosePromptLabel.text = NSLocalizedString("Choose...", comment: "")
        
        channelViewTopConstraint.constant = 30
        
        skillPickerView.dataSource = self
        skillPickerView.delegate = self
        
        skillPickerView.alpha = 0
        
        let hasSkill = (pickedSkill != nil)
        pickedSkillLabel.alpha = hasSkill ? 1 : 0
        
        channelView.backgroundColor = UIColor.whiteColor()
        channelView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewTaskViewController.showSkillPickerView(_:)))
        channelView.addGestureRecognizer(tap)
        
        mediaCollectionView.hidden = false
        mediaCollectionViewHeightConstraint.constant = 80
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
                    
                    photoFileName = "task_image_" + String(image.hash)
                    self?.imagesDictionary[photoFileName!] = image
//                    print(self?.imagesDictionary["task_image" + String(image.hash)])
                }
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func showSkillPickerView(tap: UITapGestureRecognizer) {
        
        // 初次 show，预先 selectRow

        self.messageTextView.endEditing(true)
        
        if pickedSkill == nil {
            if !skills.isEmpty {
                //let centerRow = max / 2
                //let selectedRow = centerRow
                let selectedRow = 0
                skillPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                
                pickedSkill = skills[selectedRow % skills.count]
            }
            
        } else {
            if let skill = preparedSkill, let index = skills.indexOf(skill) {
            
                //var selectedRow = max / 2
                //selectedRow = selectedRow - selectedRow % skills.count + index
                let selectedRow = index

                skillPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                pickedSkill = skills[selectedRow % skills.count]
            }
            
            preparedSkill = nil // 再 show 就不需要 selectRow 了
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in
            
            self?.channelView.backgroundColor = UIColor.clearColor()
            self?.channelViewTopLineView.alpha = 0
            self?.channelViewBottomLineView.alpha = 0
            self?.choosePromptLabel.alpha = 0

            self?.pickedSkillLabel.alpha = 0
            
            self?.skillPickerView.alpha = 1
            
            self?.channelViewTopConstraint.constant = 108
            self?.view.layoutIfNeeded()
            
        }, completion: { [weak self] _ in
            self?.channelView.userInteractionEnabled = false
        })
    }

    private func hideSkillPickerView() {
        
        if pickedSkill == generalSkill {
            pickedSkill = nil
        }
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] in
            
            self?.channelView.backgroundColor = UIColor.whiteColor()
            self?.channelViewTopLineView.alpha = 1
            self?.channelViewBottomLineView.alpha = 1
            self?.choosePromptLabel.alpha = 1
            
            if let _ = self?.pickedSkill {
                self?.pickedSkillLabel.alpha = 1
                print(self?.pickedSkillLabel.text)
            }
            
            self?.skillPickerView.alpha = 0
            
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
    /*
    func tryMakeUploadingFeed() -> DiscoveredFeed? {

//        guard let
//            myUserID = YepUserDefaults.userID.value,
//            realm = try? Realm(),
//            me = userWithUserID(myUserID, inRealm: realm) else {
//                return nil
//        }

//        let creator = DiscoveredUser.fromUser(me)

        var kind: FeedKind = .Text

        let createdUnixTime = NSDate().timeIntervalSince1970
        let updatedUnixTime = createdUnixTime

        let message = messageTextView.text.trimming(.WhitespaceAndNewline)

        var feedAttachment: DiscoveredFeed.Attachment?

        switch attachment {

        case .Default:

            if !mediaImages.isEmpty {
                kind = .Image

                let imageAttachments: [DiscoveredAttachment] = mediaImages.map({ image in

                    let imageWidth = image.size.width
                    let imageHeight = image.size.height

                    let fixedImageWidth: CGFloat
                    let fixedImageHeight: CGFloat

                    if imageWidth > imageHeight {
                        fixedImageWidth = min(imageWidth, YepConfig.Media.miniImageWidth)
                        fixedImageHeight = imageHeight * (fixedImageWidth / imageWidth)
                    } else {
                        fixedImageHeight = min(imageHeight, YepConfig.Media.miniImageHeight)
                        fixedImageWidth = imageWidth * (fixedImageHeight / imageHeight)
                    }

                    let fixedSize = CGSize(width: fixedImageWidth, height: fixedImageHeight)

                    // resize to smaller, not need fixRotation

                    if let image = image.resizeToSize(fixedSize, withInterpolationQuality: .Medium) {
                        return DiscoveredAttachment(metadata: "", URLString: "", image: image)
                    } else {
                        return nil
                    }
                }).flatMap({ $0 })

                feedAttachment = .Images(imageAttachments)
            }

        default:
            break
        }

        return DiscoveredFeed(id: "", allowComment: true, kind: kind, createdUnixTime: createdUnixTime, updatedUnixTime: updatedUnixTime, creator: creator, body: message, attachment: feedAttachment, distance: 0, skill: nil, groupID: "", messagesCount: 0, uploadingErrorMessage: nil)
    }
*/
    @objc private func post(sender: UIBarButtonItem) {
        post(again: false)
    }
    
    func post(again again: Bool) {
        
        // 任务描述字段的长度控制
        let messageLength = (messageTextView.text as NSString).length
        
        guard messageLength <= YepConfig.maxFeedTextLength else {
            let message = String(format: NSLocalizedString("Task info is too long!\nUp to %d letters.", comment: ""), YepConfig.maxFeedTextLength)
            YepAlert.alertSorry(message: message, inViewController: self)
            return
        }
        
        if !again {
            
            self.dismissViewControllerAnimated(true, completion: nil)
//            SVProgressHUD.showWithStatus("正在提交")
            // 上传图片
            WISDataManager.sharedInstance().storeImageOfMaintenanceTaskWithTaskID(nil, images: imagesDictionary, uploadProgressIndicator: { progress in
                NSLog("Upload progress is %f", progress.fractionCompleted)
                }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                if completedWithNoError {
                    // 图片上传成功，新建任务单
                    let images: Array<WISFileInfo> = data as! Array<WISFileInfo>
                    
                    for image in images {
                        self.applicationFileInfo[image.fileName] = image
                    }
                    
                    WISDataManager.sharedInstance().applyNewMaintenanceTaskWithApplicationContent(self.messageTextView.text, processSegmentID: self.pickedSkill?.id, applicationImageInfo: self.applicationFileInfo, completionHandler: { (completedWithNoError, error) -> Void in
                        if completedWithNoError {
                            
                            SVProgressHUD.showSuccessWithStatus("提交成功")
//                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        } else {
                            
                            guard let errorCode = WISErrorCode(rawValue: error.code) else {
                                SVProgressHUD.showErrorWithStatus("数据错误")
                                return
                            }
                            
                            switch errorCode {
                                
                            case .ErrorCodeResponsedNULLData:
                                
                                SVProgressHUD.showErrorWithStatus("提交失败")
                                
                            case .ErrorCodeNoCurrentUserInfo:
                                
                                SVProgressHUD.showErrorWithStatus("请重新登录")
                                
                                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                                    appDelegate.window?.rootViewController = LoginViewController()
                                }
                                
                            default:
                                
                                SVProgressHUD.showErrorWithStatus("登陆失败")
                            }
                        }
                    })
                } else {
                    
                    guard let errorCode = WISErrorCode(rawValue: error.code) else {
                        SVProgressHUD.showErrorWithStatus("数据错误")
                        return
                    }
                    
                    switch errorCode {
                        
                    case .ErrorCodeResponsedNULLData:
                        
                        SVProgressHUD.showErrorWithStatus("提交失败")
                        
                    case .ErrorCodeInvalidOperation:
                        
                        SVProgressHUD.showErrorWithStatus("数据错误")
                        
                    case .ErrorCodeNetworkTransmission:
                        
                        SVProgressHUD.showErrorWithStatus("网络异常")
                        
                    case .ErrorCodeNoCurrentUserInfo:
                        
                        SVProgressHUD.showErrorWithStatus("请重新登录")
                        
                        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                            appDelegate.window?.rootViewController = LoginViewController()
                        }
                        
                    default:
                        
                        SVProgressHUD.showErrorWithStatus("登陆失败")
                    }
                }
            })
        }
    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }
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
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            
        case 0:
            mediaImages.removeAtIndex(indexPath.item)
            //            if !imageAssets.isEmpty {
            //                imageAssets.removeAtIndex(indexPath.item)
            //            }
            collectionView.deleteItemsAtIndexPaths([indexPath])
            
        case 1:

            messageTextView.resignFirstResponder()
            
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

        isDirty = NSString(string: textView.text).length > 0
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        hideSkillPickerView()
    }
}

// MARK: - UIScrollViewDelegate

extension NewTaskViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        messageTextView.resignFirstResponder()
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension NewTaskViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return skills.isEmpty ? 0 : 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return skills.count
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let skill = skills[row % skills.count]
        
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
        
        pickedSkill = skills[row % skills.count]
//        print(pickedSkill)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension NewTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
