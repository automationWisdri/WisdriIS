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
import Navi
import SVProgressHUD

class ProfileViewController: BaseViewController {

    struct Notification {
        static let Logout = "LogoutNotification"
    }

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var avatarImageViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var mobileLabel: UILabel!

    @IBOutlet private weak var editProfileTableView: TPKeyboardAvoidingTableView!
    
    private let editPhoneSegueIdentifiler = "editPhone"

    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()

    private var codeScanNotificationToken : String?
    
    private let profileLessInfoCellIdentifier = "ProfileLessInfoCell"
    private let profileColoredTitleCellIdentifier = "ProfileColoredTitleCell"
    
    var currentUser = WISDataManager.sharedInstance().currentUser

    private var introduction: String {
        return YepUserDefaults.introduction.value ?? NSLocalizedString("No Introduction yet.", comment: "")
    }

    private let introAttributes = [NSFontAttributeName: YepConfig.EditProfile.introFont]

    private struct Listener {
        static let Title = "EditProfileLessInfoCell.Title"
        static let Mobile = "EditProfileLessInfoCell.Mobile"
        static let Password = "EditProfileLessInfoCell.Password"
        static let About = "EditProfileLessInfoCell.About"
    }

    deinit {
//        YepUserDefaults.nickname.removeListenerWithName(Listener.Nickname)
//        YepUserDefaults.introduction.removeListenerWithName(Listener.Introduction)
//        YepUserDefaults.badge.removeListenerWithName(Listener.Badge)

        editProfileTableView?.delegate = nil

        print("deinit EditProfileViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Profile", comment: "")

        let avatarSize = YepConfig.editProfileAvatarSize()
        avatarImageViewWidthConstraint.constant = avatarSize

//        let scanButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(ProfileViewController.scan(_:)))
//        scanButton.image = UIImage(named: "CodeScan.bundle/device_scan.png")
//        navigationItem.leftBarButtonItem = scanButton
//        updateAvatar() {}

        mobileLabel.text = currentUser?.fullName

        editProfileTableView.registerNib(UINib(nibName: profileLessInfoCellIdentifier, bundle: nil), forCellReuseIdentifier: profileLessInfoCellIdentifier)
        editProfileTableView.registerNib(UINib(nibName: profileColoredTitleCellIdentifier, bundle: nil), forCellReuseIdentifier: profileColoredTitleCellIdentifier)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    // MARK: Actions

    private func updateAvatar(completion:() -> Void) {
        if let avatarURLString = YepUserDefaults.avatarURLString.value {

            print("avatarURLString: \(avatarURLString)")

            let avatarSize = YepConfig.editProfileAvatarSize()
            let avatarStyle: AvatarStyle = .RoundedRectangle(size: CGSize(width: avatarSize, height: avatarSize), cornerRadius: avatarSize * 0.5, borderWidth: 0)
            
            var imagesInfo = [String : WISFileInfo]()
            
            for item : AnyObject in currentUser.imagesInfo.allKeys {
                imagesInfo[item as! String] = currentUser.imagesInfo.objectForKey(item) as? WISFileInfo
            }
            
//            let plainAvatar = PlainAvatar(avatarURLString: avatarURLString, avatarStyle: avatarStyle)
//            avatarImageView.navi_setAvatar(plainAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
            WISDataManager.sharedInstance().obtainImageOfUserWithUserName(currentUser.userName, imagesInfo: imagesInfo, downloadProgressIndicator: { progress in
                //
                }, completionHandler: { (completedWithNoError, error, classNameOfDataAsString, data) in
//                    avatarImageView = 
                    // 图片获取成功
                    let imagesDictionary = data as! Dictionary<String, UIImage>
                    
//                    UIView.transitionWithView(self, duration: imageFadeTransitionDuration, options: .TransitionCrossDissolve, animations: { () -> Void in
//                        self.image = imagesDictionary[file.fileName]
//                        }, completion: nil)
//                    avatarImageView = imagesDictionary[currentUser.imagesInfo]
            })
            
            completion()
        }
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

//    @objc private func saveIntroduction(sender: UIBarButtonItem) {
//
//        let introductionCellIndexPath = NSIndexPath(forRow: InfoRow.Intro.rawValue, inSection: Section.Info.rawValue)
//        if let introductionCell = editProfileTableView.cellForRowAtIndexPath(introductionCellIndexPath) as? EditProfileMoreInfoCell {
//            introductionCell.infoTextView.resignFirstResponder()
//        }
//    }
    
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
            vc.segueIdentifier = self.editPhoneSegueIdentifiler
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
        case Title = 0
        case Mobile
        case Password
        case Scan
        case About
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case Section.Info.rawValue:
            return 5

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

            case InfoRow.Title.rawValue:

                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell

                cell.annotationLabel.text = NSLocalizedString("Title", comment: "")
                if currentUser.roleName == nil || currentUser.roleName.isEmpty {
                    cell.infoLabel.text = NSLocalizedString("None", comment: "")
                    cell.selectionStyle = .None
                } else {
                    cell.infoLabel.text = currentUser.roleName //+ "炼钢厂－1＃炉－炉长"
                    cell.selectionStyle = .Default
                }
                
                cell.accessoryImageView.hidden = false
                
//                if let
//                    myUserID = YepUserDefaults.userID.value,
//                    realm = try? Realm(),
//                    me = userWithUserID(myUserID, inRealm: realm) {
//                        username = me.username
//                }

                return cell

            case InfoRow.Mobile.rawValue:

                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell

                cell.annotationLabel.text = NSLocalizedString("Phone Number", comment: "")
                if currentUser.cellPhoneNumber == nil || currentUser.cellPhoneNumber.isEmpty {
                    cell.infoLabel.text = NSLocalizedString("None", comment: "")
                    cell.selectionStyle = .None
                } else {
                    cell.infoLabel.text = currentUser.cellPhoneNumber
                    cell.selectionStyle = .Default
                }
                cell.accessoryImageView.hidden = false

//                YepUserDefaults.nickname.bindAndFireListener(Listener.Nickname) { [weak cell] nickname in
//                    dispatch_async(dispatch_get_main_queue()) {
//                        cell?.infoLabel.text = nickname
//                    }
//                }

                return cell

            case InfoRow.Password.rawValue:

                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell

                cell.annotationLabel.text = "修改密码"
                cell.infoLabel.hidden = true
                cell.accessoryImageView.hidden = false
                cell.selectionStyle = .Default
//                YepUserDefaults.introduction.bindAndFireListener(Listener.Introduction) { [weak cell] introduction in
//                    dispatch_async(dispatch_get_main_queue()) {
//                        cell?.infoTextView.text = introduction ?? NSLocalizedString("Introduce yourself here.", comment: "")
//                    }
//                }

//                cell.infoTextViewIsDirtyAction = { [weak self] isDirty in
//                    self?.navigationItem.rightBarButtonItem = self?.doneButton
//                    self?.doneButton.enabled = isDirty
//                }
//
//                cell.infoTextViewDidEndEditingAction = { [weak self] newIntroduction in
//                    self?.doneButton.enabled = false
//
//                    if let oldIntroduction = YepUserDefaults.introduction.value {
//                        if oldIntroduction == newIntroduction {
//                            return
//                        }
//                    }

//                    YepHUD.showActivityIndicator()

//                    updateMyselfWithInfo(["introduction": newIntroduction], failureHandler: { (reason, errorMessage) in
//                        defaultFailureHandler(reason, errorMessage: errorMessage)
//
//                        YepHUD.hideActivityIndicator()
//
//                    }, completion: { success in
//                        dispatch_async(dispatch_get_main_queue()) {
//                            YepUserDefaults.introduction.value = newIntroduction
//
//                            self?.editProfileTableView.reloadData()
//                        }
//
//                        YepHUD.hideActivityIndicator()
//                    })
//                }

                return cell
                
            case InfoRow.Scan.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(profileLessInfoCellIdentifier) as! ProfileLessInfoCell
                
                cell.annotationLabel.text = "打卡扫一扫"
                
                switch currentClockStatus {
                case 1:
                    cell.infoLabel.hidden = false
                    cell.infoLabel.text = "上班中"
                    cell.infoLabel.textColor = UIColor.yepTintColor()
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

            case InfoRow.Title.rawValue:
                return 60

            case InfoRow.Mobile.rawValue:
                return 60

            case InfoRow.Password.rawValue:
                return 60
                
            case InfoRow.Scan.rawValue:
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
                    
            case InfoRow.Password.rawValue:
                
                performSegueWithIdentifier("editPassword", sender: nil)

            case InfoRow.Mobile.rawValue:
                
                performSegueWithIdentifier("editPhone", sender: nil)
                
            case InfoRow.Scan.rawValue:
                
                self.codeScanNotificationToken = CodeScanViewController.performPresentToCodeScanViewController(self, completion: nil)
                
                if self.codeScanNotificationToken != nil {
                    WISDataManager.sharedInstance().submitClockActionWithCompletionHandler({ (completedWithNoError, error, classNameOfDataAsString, data) in
                        if completedWithNoError {
                            
                            SVProgressHUD.showWithStatus("打卡成功")
                            currentClockStatus = data as! Int
                            print(currentClockStatus)
                            self.editProfileTableView.reloadData()
                            SVProgressHUD.dismiss()
                            
                            
                        } else {
                            
                            errorCode(error)
                        }
                        
                    })
                }

            default:
                break
            }

        case Section.LogOut.rawValue:

            YepAlert.confirmOrCancel(title: NSLocalizedString("Notice", comment: ""), message: NSLocalizedString("Do you want to logout?", comment: ""), confirmTitle: NSLocalizedString("Yes", comment: ""), cancelTitle: NSLocalizedString("Cancel", comment: ""), inViewController: self, withConfirmAction: { () -> Void in

//                unregisterThirdPartyPush()

//                cleanRealmAndCaches()

                YepUserDefaults.cleanAllUserDefaults()
                
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

        let image = image.largestCenteredSquareImage().resizeToTargetSize(YepConfig.avatarMaxSize())
        let imageData = UIImageJPEGRepresentation(image, YepConfig.avatarCompressionQuality())

        if let imageData = imageData {
/*
            updateAvatarWithImageData(imageData, failureHandler: { (reason, errorMessage) in

                defaultFailureHandler(reason, errorMessage: errorMessage)

                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.activityIndicator.stopAnimating()
                }
                
            }, completion: { newAvatarURLString in
                dispatch_async(dispatch_get_main_queue()) {

                    YepUserDefaults.avatarURLString.value = newAvatarURLString

                    print("newAvatarURLString: \(newAvatarURLString)")

                    self.updateAvatar() {
                        dispatch_async(dispatch_get_main_queue()) { [weak self] in
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                }
            })
 */
        }
    }
}
