//
//  ProfileViewController.swift
//  WisdriIS
//
//  Created by Allen on 3/1/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import Proposer
import SVProgressHUD
import Navi

class ProfileViewController: BaseViewController {

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var avatarImageViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var roleLabel: UILabel!

    @IBOutlet private weak var editProfileTableView: TPKeyboardAvoidingTableView!
    
    private let editPhoneSegueIdentifier = "editPhone"
    private let editUserNameSegueIdentifier = "editUserName"

    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()

    private var codeScanNotificationToken : String?
    
    private let profileLessInfoCellIdentifier = "ProfileLessInfoCell"
    private let profileColoredTitleCellIdentifier = "ProfileColoredTitleCell"
    
    private var currentUser: WISUser!

    deinit {

        editProfileTableView?.delegate = nil

        print("deinit EditProfileViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Profile", comment: "")

        // avatar size is 100
        let avatarSize = WISConfig.profileAvatarSize()
        avatarImageViewWidthConstraint.constant = avatarSize
        updateAvatar() {}
        
        roleLabel.text = currentUser?.roleName

        editProfileTableView.registerNib(UINib(nibName: profileLessInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: profileLessInfoCellIdentifier)
        editProfileTableView.registerNib(UINib(nibName: profileColoredTitleCellIdentifier, bundle: nil), forCellReuseIdentifier: profileColoredTitleCellIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        editProfileTableView.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    // MARK: Actions

    private func updateAvatar(completion:() -> Void) {

        currentUser = WISDataManager.sharedInstance().currentUser
        
        let avatarSize = WISConfig.profileAvatarSize()
        
        var imagesInfo = [String : WISFileInfo]()
        
        guard currentUser.imagesInfo.count > 0 else {
            self.avatarImageView.image = UIImage(named: "default_avatar_60")
            return
        }
        
        for item : AnyObject in currentUser.imagesInfo.allKeys {
            imagesInfo[item as! String] = currentUser.imagesInfo.objectForKey(item) as? WISFileInfo
        }
        
        WISDataManager.sharedInstance().obtainImageOfUserWithUserName(currentUser.userName, imagesInfo: imagesInfo, downloadProgressIndicator: { progress in
            
            }) { (completedWithNoError, error, classNameOfDataAsString, data) in
                if completedWithNoError {
                    // 图片获取成功
                    let imagesDictionary = data as! Dictionary<String, UIImage>
                    
                    UIView.transitionWithView(self.avatarImageView, duration: imageFadeTransitionDuration, options: .TransitionCrossDissolve, animations: {
                        if let avatarOriginalImage = imagesDictionary.first?.1,
                            let avatarResizeImage = avatarOriginalImage.navi_resizeToSize(CGSize(width: avatarSize, height: avatarSize), withInterpolationQuality: CGInterpolationQuality.Default),
                            let avatarRoundImage = avatarResizeImage.navi_roundWithCornerRadius(avatarSize * 0.5, borderWidth: 0) {
                            self.avatarImageView.image = avatarRoundImage
                        } else {
                            self.avatarImageView.image = UIImage(named: "default_avatar_60")
                        }
                        }, completion: { _ in
                            
                    })
                    
                } else {
                    self.avatarImageView.image = UIImage(named: "default_avatar_60")
                }
        }
        
        completion()
    }

    @IBAction private func changeAvatar(sender: UITapGestureRecognizer) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        let choosePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose Photo", comment: ""), style: .Default) { action -> Void in

            let openCameraRoll: ProposerAction = { [weak self] in

                guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
                    self?.alertCanNotAccessCameraRoll()
                    return
                }

                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .PhotoLibrary
                    strongSelf.presentViewController(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }

            proposeToAccess(.Photos, agreed: openCameraRoll, rejected: {
                self.alertCanNotAccessCameraRoll()
            })
        }
        alertController.addAction(choosePhotoAction)

        let takePhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .Default) { action -> Void in

            let openCamera: ProposerAction = { [weak self] in

                guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
                    self?.alertCanNotOpenCamera()
                    return
                }

                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .Camera
                    strongSelf.presentViewController(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }

            proposeToAccess(.Camera, agreed: openCamera, rejected: {
                self.alertCanNotOpenCamera()
            })
        }
        alertController.addAction(takePhotoAction)

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true, completion: nil)

        // touch to create (if need) for faster appear
        delay(0.2) { [weak self] in
            self?.imagePicker.hidesBarsOnTap = false
        }
    }
    
    @objc private func scan(sender: UIBarButtonItem) {
        
        self.presentViewController(CodeScanViewController(), animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "editPhone":
            let vc = segue.destinationViewController as! ProfileInfoViewController
            vc.segueIdentifier = self.editPhoneSegueIdentifier
        case "editUserName":
            let vc = segue.destinationViewController as! ProfileInfoViewController
            vc.segueIdentifier = self.editUserNameSegueIdentifier
        default:
            break
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    private enum Section: Int {
        case Info
        case LogOut
    }

    private enum InfoRow: Int {
        case Name = 0
        case Phone
        case Password
        case Scan
        case Notification
        case About
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case Section.Info.rawValue:
            return 6

        case Section.LogOut.rawValue:
            return 1

        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.section {

        case Section.Info.rawValue:

            switch indexPath.row {

            case InfoRow.Name.rawValue:

                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell

                cell.annotationLabel.text = NSLocalizedString("Name", comment: "")
                if currentUser.fullName == nil || currentUser.fullName.isEmpty {
                    cell.infoLabel.text = NSLocalizedString("None", comment: "")
                    cell.selectionStyle = .None
                } else {
                    cell.infoLabel.text = currentUser.fullName
                    cell.selectionStyle = .Default
                }
                
                cell.accessoryImageView.hidden = false

                return cell

            case InfoRow.Phone.rawValue:

                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell

                cell.annotationLabel.text = NSLocalizedString("Phone Number", comment: "")
                if currentUser.cellPhoneNumber == nil || currentUser.cellPhoneNumber.isEmpty {
                    cell.infoLabel.text = NSLocalizedString("None", comment: "")
                } else {
                    cell.infoLabel.text = currentUser.cellPhoneNumber
                }
                cell.selectionStyle = .Default
                cell.accessoryImageView.hidden = false

                return cell

            case InfoRow.Password.rawValue:

                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell

                cell.annotationLabel.text = "修改密码"
                cell.infoLabel.hidden = true
                cell.accessoryImageView.hidden = false
                cell.selectionStyle = .Default

                return cell
                
            case InfoRow.Scan.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell
                
                cell.annotationLabel.text = "打卡扫一扫"
                
                switch currentClockStatus {
                case 1:
                    cell.infoLabel.hidden = false
                    cell.infoLabel.text = "上班中"
                    cell.infoLabel.textColor = UIColor.wisTintColor()
                case 2:
                    cell.infoLabel.hidden = false
                    cell.infoLabel.text = "已下班"
                    cell.infoLabel.textColor = UIColor.darkGrayColor()
                default:
                    cell.infoLabel.hidden = true
                }
                
                cell.accessoryImageView.hidden = false
                cell.selectionStyle = .Default
                
                return cell
                
            case InfoRow.Notification.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell
                
                cell.annotationLabel.text = NSLocalizedString("Notification Received", comment: "")
                cell.infoLabel.hidden = true
                cell.accessoryImageView.hidden = false
                cell.selectionStyle = .Default
                
                return cell
                
            case InfoRow.About.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell
                
                cell.annotationLabel.text = "关于"
                cell.infoLabel.hidden = true
                cell.accessoryImageView.hidden = false
                cell.selectionStyle = .Default
                
                return cell
                
            default:
                return UITableViewCell()
            }

        case Section.LogOut.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(profileColoredTitleCellIdentifier) as! ProfileColoredTitleCell
            cell.coloredTitleLabel.text = "退出登录"
            cell.coloredTitleColor = UIColor.redColor()
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch indexPath.section {

        case Section.Info.rawValue:

            switch indexPath.row {

            case InfoRow.Name.rawValue:
                return 60

            case InfoRow.Phone.rawValue:
                return 60

            case InfoRow.Password.rawValue:
                return 60
                
            case InfoRow.Scan.rawValue:
                return 60
                
            case InfoRow.Notification.rawValue:
                return 60
                
            case InfoRow.About.rawValue:
                return 60

            default:
                return 0
            }

        case Section.LogOut.rawValue:
            return 60

        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        switch indexPath.section {

        case Section.Info.rawValue:

            switch indexPath.row {
                
            case InfoRow.Name.rawValue:
                
                performSegueWithIdentifier("editUserName", sender: nil)
                
            case InfoRow.Password.rawValue:
                
                performSegueWithIdentifier("editPassword", sender: nil)

            case InfoRow.Phone.rawValue:
                
                performSegueWithIdentifier("editPhone", sender: nil)
                
            case InfoRow.Notification.rawValue:
                NotificationListViewController.performPushToNotificationListView(self)
                
            case InfoRow.Scan.rawValue:
                
                self.codeScanNotificationToken = CodeScanViewController.performSegueToCodeScanViewController(self, completion: nil)
                
                if self.codeScanNotificationToken != nil {
                    WISDataManager.sharedInstance().submitClockActionWithCompletionHandler({ (completedWithNoError, error, classNameOfDataAsString, data) in
                        if completedWithNoError {
                            
                            SVProgressHUD.showSuccessWithStatus("打卡成功")
                            currentClockStatus = data as! Int

                            self.editProfileTableView.reloadData()
                            
                        } else {
                            
                            WISConfig.errorCode(error)
                        }
                        
                    })
                }
                
            case InfoRow.About.rawValue:
                
                performSegueWithIdentifier("about", sender: nil)

            default:
                break
            }

        case Section.LogOut.rawValue:

            WISAlert.confirmOrCancel(title: NSLocalizedString("Notice", comment: ""), message: NSLocalizedString("Do you want to logout?", comment: ""), confirmTitle: NSLocalizedString("Yes", comment: ""), cancelTitle: NSLocalizedString("Cancel", comment: ""), inViewController: self, withConfirmAction: { () -> Void in
                
//                WISDataManager.sharedInstance().clearCacheOfImages()

                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    appDelegate.window?.rootViewController = LoginViewController()
                }

            }, cancelAction: { () -> Void in
            })

        default:
            break
        }
    }
}

// MARK: UIImagePicker

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        defer {
            dismissViewControllerAnimated(true, completion: nil)
        }

        activityIndicator.startAnimating()

        let image = image.largestCenteredSquareImage().resizeToTargetSize(WISConfig.avatarMaxSize())
//        let imageData = UIImageJPEGRepresentation(image, WISConfig.avatarCompressionQuality())

        var images = [String : UIImage]()
        
        let imageName = currentUser.userName + "_avatar_" + String(image.hashValue)
        
        images[imageName] = image
        
        WISDataManager.sharedInstance().storeImageOfUserWithUserName(currentUser.userName, images: images, uploadProgressIndicator: { (progress) in
            NSLog("Upload progress is %f", progress.fractionCompleted)
            }) { (completedWithNoError, error, classNameOfDataAsString, data) in
                if completedWithNoError {
                    // 图片上传成功
                    let images: [WISFileInfo] = data as! [WISFileInfo]
                    
                    let imagesInfo = NSMutableDictionary()
                    imagesInfo.setValue(images.first, forKey: imageName)

                    let newWISUser = self.currentUser.copy() as! WISUser
                    newWISUser.imagesInfo = imagesInfo
                    
                    WISDataManager.sharedInstance().submitUserDetailInfoWithNewInfo(newWISUser, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
                        if completedWithNoError {
                            self.updateAvatar() {
                                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                                    self?.activityIndicator.stopAnimating()
                                }
                            }
                        } else {
                            SVProgressHUD.showErrorWithStatus("获取用户头像失败")
                            self.activityIndicator.stopAnimating()
//                            WISConfig.errorCode(error)
                        }
                    })
                } else {
                    SVProgressHUD.showErrorWithStatus("上传图片失败")
                    self.activityIndicator.stopAnimating()
//                    WISConfig.errorCode(error)
                }
        }
    }
}
