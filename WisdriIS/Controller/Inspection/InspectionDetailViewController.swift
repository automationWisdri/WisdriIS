//
//  InspectionDetailViewController.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/10/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//


import UIKit
import MobileCoreServices
import SVProgressHUD
import KeyboardMan


class InspectionDetailViewController: BaseViewController {
    
    // MARK: - Properties
    
    private var codeScanNotificationToken:String?
    
    var showMoreInformation = false
    var operationEnabled = false
    
    let keyboardMan = KeyboardMan()
    
    @IBOutlet weak var inspectionDetailTableView: UITableView!
    
    var inspectionTask = WISInspectionTask()
    var indexInList = -1
    
    var superViewController: UIViewController? = nil
    
    private let inspectionDeviceInfoCellID = "InspectionDeviceInfoCell"
    private let inspectionDeviceBelongingCellID = "InspectionDeviceBelongingCell"
    private let inspectionDeviceRemarkCellID = "InspectionDeviceRemarkCell"
    
    private let inspectionDeviceTypeInfoCellID = "InspectionDeviceTypeInfoCell"
    private let inspectionDeviceTypeInformationCellID = "InspectionDeviceTypeInformationCell"
    
    private let inspectionResultSelectionCellID = "InspectionResultSelectionCell"
    private let inspectionPickPhotoCellID = "InspectionPickPhotoCell"
    
    
    /// Obsolete
    private let inspectionResultShowSelectionCellID = "InspectionResultShowSelectionCell"
    /// Obsolete
    private let inspectionShowPhotoCellID = "InspectionShowPhotoCell"
    
    
    private let inspectionPresentResultWithPhotoCellID = "InspectionPresentResultWithPhotoCell"
    
    private let inspectionResultDescriptionCellID = "InspectionResultDescriptionCell"
    
    private let inspectionColoredTitleCellID = "InspectionColoredTitleCell"
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    // MARK: - View Life Cycle Operation Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.parseScanedCode(_:)),
                                                         name: QRCodeScanedSuccessfullyNotification,
                                                         object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) registered in InspectionDetailViewController while loading view")
        
        codeScanNotificationToken = ""
        
        // Do any additional setup after loading the view.
        title = NSLocalizedString("Inspection Task Detail", comment: "")
        self.view.backgroundColor = UIColor.wisBackgroundColor()
        inspectionDetailTableView.delegate = self
        inspectionDetailTableView.dataSource = self
        
        //        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(InspectionDetailViewController.singleTapped(_:)))
        //        self.view.addGestureRecognizer(singleTap)
        
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionDeviceInfoCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionDeviceInfoCellID)
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionDeviceBelongingCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionDeviceBelongingCellID)
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionDeviceRemarkCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionDeviceRemarkCellID)
        
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionDeviceTypeInfoCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionDeviceTypeInfoCellID)
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionDeviceTypeInformationCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionDeviceTypeInformationCellID)
        
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionResultSelectionCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionResultSelectionCellID)
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionPickPhotoCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionPickPhotoCellID)
        
        /** Obsolete
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionResultShowSelectionCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionResultShowSelectionCellID)
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionShowPhotoCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionShowPhotoCellID)
        */
        
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionPresentResultWithPhotoCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionPresentResultWithPhotoCellID)
        
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionResultDescriptionCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionResultDescriptionCellID)
        
        inspectionDetailTableView.registerNib(UINib(nibName: inspectionColoredTitleCellID, bundle: nil),
                                              forCellReuseIdentifier: inspectionColoredTitleCellID)
        
        #if (arch(x86_64) || arch(i386)) && os(iOS)
            // ignore
        #else
            /// code below doesn't work 2016.05.09
            keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
                print("appear \(appearPostIndex), \(keyboardHeight), \(keyboardHeightIncrement)")
                if let strongSelf = self {
                    
                    strongSelf.view.frame.origin.y -= (keyboardHeightIncrement + 50)
                    strongSelf.view.frame.size.height += (keyboardHeightIncrement + 50)
                    strongSelf.view.layoutIfNeeded()
                }
            }
            
            keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
                print("disappear \(keyboardHeight)\n")
                if let strongSelf = self {
                    strongSelf.view.frame.origin.y += (keyboardHeight + 50)
                    strongSelf.view.frame.size.height -= (keyboardHeight + 50)
                    strongSelf.view.layoutIfNeeded()
                }
            }
        #endif
        
        getInspectionDetail()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if showMoreInformation {
            //            let cell = self.inspectionDetailTableView.cellForRowAtIndexPath(
            //                NSIndexPath.init(
            //                    forRow: InspectionResultRow.ResultSelection.rawValue, inSection: Section.InspectionResult.rawValue)) as UITableViewCell?
            //
            //            let selectionCell = (cell as? InspectionResultSelectionCell)?.inspectionResultTableView.cellForRowAtIndexPath((
            //                NSIndexPath.init(forRow: 0, inSection: 0)))
            //
            //            selectionCell?.selected = true
            //            var ss = selectionCell?.selected
            //            var ww=ss
        }
        print("InspectionDetailViewController's view will appear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("InspectionDetailViewController's view did disappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: QRCodeScanedSuccessfullyNotification, object: nil)
        print("Notification \(QRCodeScanedSuccessfullyNotification) deregistered in InspectionDetailViewController while deiniting")
    }
    
    func singleTapped(gesture: UITapGestureRecognizer) {
        // self.view.endEditing(true)
        // do nothing
    }
    
    // MARK: - Methods
    
    func getInspectionDetail() -> Void {
        // SVProgressHUD.show()
        //        WISDataManager.sharedInstance().updateMaintenanceTaskDetailInfoWithTaskID(inspectionTask?.taskID) {
        //            (completedWithNoError, error, classNameOfUpdatedDataAsString, updatedData) -> Void in
        //            if completedWithNoError {
        //                self.inspectionTaskInfo = updatedData as? WISMaintenanceTask
        //                SVProgressHUD.dismiss()
        //                self.inspectionDetailTableView.reloadData()
        //                // self.getTaskAction()
        //            }
        //        }
    }
    
    //
    @objc func parseScanedCode(notification:NSNotification) -> Void {
        if (notification.userInfo![codeScanNotificationTokenKey] as! String) == self.codeScanNotificationToken {
            // do checking jobs
            print("InspectionDetailViewController- code:\(notification.object)")
            
            let scanResult = notification.object as! String
            let scanResultAsArray = scanResult.componentsSeparatedByString("&")
            
            guard scanResultAsArray[0] == "DEVICE" && scanResultAsArray.count == 7 else {
                WISAlert.alert(title: NSLocalizedString("QRCode content not match", comment: ""), message: NSLocalizedString("Scaned QRCode is ", comment: "") + scanResult, dismissTitle: NSLocalizedString("Confirm", comment: ""), inViewController: self, withDismissAction: {
                    // do nothing
                })
                showMoreInformation = false
                return
            }
            
            guard scanResultAsArray[1] == inspectionTask.device.deviceID else {
                WISAlert.alert(title: NSLocalizedString("QRCode content not match", comment: ""), message: NSLocalizedString("QRCode does not match the device", comment: ""), dismissTitle: NSLocalizedString("Confirm", comment: ""), inViewController: self, withDismissAction: {
                    // do nothing
                })
                showMoreInformation = false
                return
            }
            
            /// for test purpose
            showMoreInformation = true
            
            if showMoreInformation {
                self.inspectionDetailTableView.reloadData()
            }
        }
        return
    }
    
    class func performPushToInspectionDetailView(superViewController:UIViewController,
                                                 inspectionTask:WISInspectionTask,
                                                 index:Int,
                                                 showMoreInformation:Bool, enableOperation:Bool) -> Void {
        
        let board = UIStoryboard.init(name: "InspectionDetail", bundle: NSBundle.mainBundle())
        let viewController = board.instantiateViewControllerWithIdentifier("InspectionDetailViewController") as! InspectionDetailViewController
        viewController.inspectionTask = inspectionTask.copy() as! WISInspectionTask
        
        viewController.showMoreInformation = showMoreInformation
        // 需要根据角色来区分详细任务信息是否可编辑(由SuperViewController决定)
        viewController.operationEnabled = enableOperation
        viewController.superViewController = superViewController
        viewController.indexInList = index
        viewController.hidesBottomBarWhenPushed = true
        superViewController.navigationController?.pushViewController(viewController, animated: true)
        superViewController.tabBarController?.tabBar.hidden = true
    }
}

// MARK: - UIScrollViewDelegate

extension InspectionDetailViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension InspectionDetailViewController:UITableViewDataSource, UITableViewDelegate {
    
    /// Number of sections in TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.count
    }
    
    /// Number of Rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .InspectionDevice:
            return InspectionDeviceRow.count
        case .InspectionDeviceType:
            return InspectionDeviceTypeRow.count
        case .InspectionResult:
            // in different situation, the return value should change
            if showMoreInformation {
                
                return operationEnabled ? InspectionAddResultRow.count : InspectionPresentResultRow.count
            } else {
                return 0
            }
            
        case .InspectionOperation:
            return operationEnabled ? InspectionOperationRow.count : 0
        }
    }
    
    /// Set height of header in section
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .InspectionDevice: return 20.0//0.001
        case .InspectionDeviceType: return 0.001//10
        case .InspectionResult: return 0.001//10
        case .InspectionOperation: return showMoreInformation ? 20.0 : 5.0
        }
    }
    
    /// Set Cells in section
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        //／ SECTION: Equip
        case .InspectionDevice:
            guard let row = InspectionDeviceRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .DeviceInfo:
                let cell = tableView.dequeueReusableCellWithIdentifier(inspectionDeviceInfoCellID) as! InspectionDeviceInfoCell
                cell.selectionStyle = .None
                cell.bindData(inspectionTask!)
                return cell
                
            case .DeviceBelonging:
                let cell = tableView.dequeueReusableCellWithIdentifier(inspectionDeviceBelongingCellID) as! InspectionDeviceBelongingCell
                cell.selectionStyle = .None
                cell.bindData(inspectionTask!)
                return cell
                
            case .DeviceRemark:
                let cell = tableView.dequeueReusableCellWithIdentifier(inspectionDeviceRemarkCellID) as! InspectionDeviceRemarkCell
                cell.selectionStyle = .None
                cell.bindData(inspectionTask!)
                return cell
            }
            
        /// SECTION: Equip Type
        case .InspectionDeviceType:
            guard let row = InspectionDeviceTypeRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .DeviceTypeInfo:
                let cell = tableView.dequeueReusableCellWithIdentifier(inspectionDeviceTypeInfoCellID) as! InspectionDeviceTypeInfoCell
                cell.selectionStyle = .None
                cell.bindData(inspectionTask!)
                return cell
                
            case .DeviceTypeInformation:
                let cell = tableView.dequeueReusableCellWithIdentifier(inspectionDeviceTypeInformationCellID) as! InspectionDeviceTypeInformationCell
                cell.selectionStyle = .None
                cell.bindData(inspectionTask!)
                return cell
            }
            
        /// SECTION: Inspection Result
        case .InspectionResult:
            if operationEnabled {
                guard let row = InspectionAddResultRow(rawValue: indexPath.row) else {
                    break
                }
                
                switch row {
                case .ResultSelection:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionResultSelectionCellID) as! InspectionResultSelectionCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!)
                    return cell
                    
                case .PickPhoto:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionPickPhotoCellID) as! InspectionPickPhotoCell
                    cell.selectionStyle = .None
                    cell.superViewController = self
                    return cell
                    
                    
                case .ResultDescription:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionResultDescriptionCellID) as! InspectionResultDescriptionCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!, editable: true)
                    return cell
                }
                
            } else {
                guard let row = InspectionPresentResultRow(rawValue: indexPath.row) else {
                    break
                }
                
                /** InspectionShowResultRow -- Obsolete 2016.05.22
                switch row {
                case .Result:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionResultShowSelectionCellID) as! InspectionResultShowSelectionCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!)
                    return cell
                    
                case .ShowPhoto:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionShowPhotoCellID) as! InspectionShowPhotoCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!)
                    
                    return cell
                    
                    
                case .ResultDescription:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionResultDescriptionCellID) as! InspectionResultDescriptionCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!, editable: false)
                    return cell
                }
                */
                
                switch row {
                case .ResultWithPhoto:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionPresentResultWithPhotoCellID) as! InspectionPresentResultWithPhotoCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!)
                    return cell
                    
                case .ResultDescription:
                    let cell = tableView.dequeueReusableCellWithIdentifier(inspectionResultDescriptionCellID) as! InspectionResultDescriptionCell
                    cell.selectionStyle = .None
                    cell.bindData(inspectionTask!, editable: false)
                    return cell
                }
            }
            
        // Section: Operation
        case .InspectionOperation:
            guard let row = InspectionOperationRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .Action:
                let cell = tableView.dequeueReusableCellWithIdentifier(inspectionColoredTitleCellID) as! InspectionColoredTitleCell
                cell.selectionStyle = .Gray
                cell.coloredTitleColor = UIColor.wisTintColor()
                cell.coloredTitleLabel.textAlignment = NSTextAlignment.Center
                cell.coloredTitleLabel.font = UIFont.systemFontOfSize(18.0)
                if showMoreInformation {
                    cell.coloredTitleLabel.text = NSLocalizedString("Submit Inspection Result")
                } else {
                    cell.coloredTitleLabel.text = NSLocalizedString("Scan QRCode")
                }
                // more settings on the cell
                return cell
            }
            
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    // Set height of row
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            return 0.0
        }
        
        switch section {
        // Section: Device
        case .InspectionDevice:
            guard let row = InspectionDeviceRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .DeviceInfo: return InspectionDeviceInfoCell.cellHeight
            case .DeviceBelonging: return InspectionDeviceBelongingCell.cellHeight
            case .DeviceRemark: return InspectionDeviceRemarkCell.cellHeight
            }
            
        /// Section: Device Type
        case .InspectionDeviceType:
            guard let row = InspectionDeviceTypeRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .DeviceTypeInfo: return InspectionDeviceTypeInfoCell.cellHeight
            case .DeviceTypeInformation: return InspectionDeviceTypeInformationCell.cellHeight
            }
            
        /// Section: Inspection Result
        case .InspectionResult:
            if operationEnabled {
                guard let row = InspectionAddResultRow(rawValue: indexPath.row) else {
                    break
                }
                
                switch row {
                case .ResultSelection: return InspectionResultSelectionCell.cellHeight
                case .PickPhoto: return InspectionPickPhotoCell.cellHeight
                case .ResultDescription: return InspectionResultDescriptionCell.cellHeight
                }
                
            } else {
                guard let row = InspectionPresentResultRow(rawValue: indexPath.row) else {
                    break
                }
                /** Obsolete
                switch row {
                case .Result: return InspectionResultShowSelectionCell.cellHeight
                case .ShowPhoto: return InspectionShowPhotoCell.calCellHeight(self.inspectionTask)
                case .ResultDescription: return InspectionResultDescriptionCell.cellHeight
                }
                */
                
                switch row {
                case .ResultWithPhoto: return InspectionPresentResultWithPhotoCell.calCellHeight(self.inspectionTask)
                case .ResultDescription: return InspectionResultDescriptionCell.cellHeight
                }
                
            }
            
        // Section: Operation
        case .InspectionOperation:
            guard let row = InspectionOperationRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .Action: return InspectionColoredTitleCell.cellHeight
            }
            
        default:
            return 0.0
        }
        return 0.0
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
        case .InspectionOperation:
            guard let row = InspectionOperationRow(rawValue: indexPath.row) else {
                break
            }
            
            switch row {
            case .Action:
                //／ SUBMIT INSPECTION RESULT
                if showMoreInformation {
                    WISAlert.confirmOrCancel(
                        title: NSLocalizedString("Submit Inspection Result"),
                        message: NSLocalizedString("Do you want to submit inspection result?"),
                        confirmTitle: NSLocalizedString("Confirm"),
                        cancelTitle: NSLocalizedString("Cancel"),
                        inViewController: self,
                        
                        withConfirmAction: {[weak self] () -> Void in
                            // cleanRealmAndCaches()
                            // YepUserDefaults.cleanAllUserDefaults()
                            
                            var indexPath = NSIndexPath(forRow: InspectionAddResultRow.ResultSelection.rawValue, inSection: Section.InspectionResult.rawValue)
                            let cellResultSelection = tableView.cellForRowAtIndexPath(indexPath) as! InspectionResultSelectionCell
                            cellResultSelection.bringBackData(&self!.inspectionTask!)
                            
                            indexPath = NSIndexPath(forRow: InspectionAddResultRow.PickPhoto.rawValue, inSection: Section.InspectionResult.rawValue)
                            let cellPickPhoto = tableView.cellForRowAtIndexPath(indexPath) as! InspectionPickPhotoCell
                            let images = cellPickPhoto.mediaImages
                            
                            var imagesInDictionary = [String:UIImage]()
                            
                            if images.count > 0 {
                                for image in images {
                                    // set images name
                                    imagesInDictionary["inspectionTask_image_" + String(image.hashValue)] = image
                                }
                            }
                            
                            indexPath = NSIndexPath(forRow: InspectionAddResultRow.ResultDescription.rawValue, inSection: Section.InspectionResult.rawValue)
                            let cellResultDescription = tableView.cellForRowAtIndexPath(indexPath) as! InspectionResultDescriptionCell
                            cellResultDescription.bringBackData(&self!.inspectionTask!)
                            
                            if self?.inspectionTask.inspectionResult == .DeviceFaultForHandle && self?.inspectionTask.inspectionResultDescription == "" {
                                WISAlert.alert(title: NSLocalizedString("Submit Inspection Result"), message: NSLocalizedString("Result description is needed when device is fault"), dismissTitle: NSLocalizedString("Confirm"), inViewController: self, withDismissAction: nil)
                                return
                            }
                            
                            self!.inspectionTask!.inspectionFinishedTime = NSDate.init(timeIntervalSinceNow: NSTimeInterval.init(0.0))
                            
                            WISInsepctionDataManager.sharedInstance().addInspectionTaskToUploadingQueue(self!.inspectionTask!, images: imagesInDictionary)
                            
                            // if submit successfully
                            WISAlert.alert(
                                title: NSLocalizedString("Submit Inspection Result"),
                                message: NSLocalizedString("Submit Inspection Result Successfully!"),
                                dismissTitle: NSLocalizedString("Confirm"),
                                inViewController: self,
                                
                                withDismissAction: {[weak self] () -> Void in
                                    if self!.indexInList > -1 {
                                        WISInsepctionDataManager.sharedInstance().onTheGoInspectionTasks.removeAtIndex(self!.indexInList)
                                    }
                                    self!.navigationController?.popViewControllerAnimated(true)
                                })
                        },
                        cancelAction: {/*[weak self]*/ () -> Void in
                            // do something
                            
                    })
                    
                    /// SCAN QRCODE
                } else {
                    self.codeScanNotificationToken = CodeScanViewController.performPresentToCodeScanViewController(self) {
                        // do nothing
                    }
                    print("code scan notification token: \n\(self.codeScanNotificationToken)")
                }
                
                // default: return
            }
            
        default: return
        }
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
        case .InspectionResult:
            guard let cell = cell as? InspectionPresentResultWithPhotoCell else {
                break
            }
            
            cell.tapMediaAction = { [weak self] transitionView, image, imageFileInfos, index in
                guard image != nil else {
                    return
                }
                
                let viewController = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewControllerWithIdentifier("MediaPreviewViewController") as! MediaPreviewViewController
                
                viewController.previewImages = imageFileInfos
                viewController.startIndex = index
                
                let transitionView = transitionView
                let frame = transitionView.convertRect(transitionView.frame, toView: self?.view)
                viewController.previewImageViewInitalFrame = frame
                viewController.bottomPreviewImage = image
                viewController.transitionView = transitionView
                
                self?.view.endEditing(true)
                
                delay(0.3, work: { () -> Void in
                    transitionView.alpha = 0
                })
                
                viewController.afterDismissAction = { [weak self] in
                    transitionView.alpha = 1
                    mediaPreviewWindow.hidden = true
                    self?.view.window?.makeKeyAndVisible()
                }
                
                mediaPreviewWindow.rootViewController = viewController
                mediaPreviewWindow.makeKeyAndVisible()
            }
            break
            
        default:
            break
        }
    }
    
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension InspectionDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            let stringKUTTypeImage = kUTTypeImage as String
            switch mediaType {
            case stringKUTTypeImage:
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    let cell = self.inspectionDetailTableView.cellForRowAtIndexPath(
                        NSIndexPath.init(forRow: InspectionAddResultRow.PickPhoto.rawValue,
                            inSection: Section.InspectionResult.rawValue)) as! InspectionPickPhotoCell
                    if cell.mediaImages.count <= cell.imageCountUpLimit - 1 {
                        cell.mediaImages.append(image)
                    }
                }
                
            default:
                break
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - Constants ENUM

private enum Section: Int {
    case InspectionDevice = 0
    case InspectionDeviceType = 1
    case InspectionResult = 2
    case InspectionOperation = 3
    
    static let count: Int = {
        return 4
    }()
}

private enum InspectionDeviceRow: Int {
    case DeviceInfo = 0
    case DeviceBelonging = 1
    case DeviceRemark = 2
    
    static let count: Int = {
        return 3
    }()
}

private enum InspectionDeviceTypeRow: Int {
    case DeviceTypeInfo = 0
    case DeviceTypeInformation = 1
    
    static let count: Int = {
        return 2
    }()
}

private enum InspectionAddResultRow: Int {
    case ResultSelection = 0
    case PickPhoto = 1
    case ResultDescription = 2
    
    static let count: Int = {
        return 3
    }()
}

/// Obsolete
private enum InspectionShowResultRow: Int {
    case Result = 0
    case ShowPhoto = 1
    case ResultDescription = 2
    
    static let count: Int = {
        return 3
    }()
}

private enum InspectionPresentResultRow: Int {
    case ResultWithPhoto = 0
    case ResultDescription = 1
    
    static let count: Int = {
        return 2
    }()
}


private enum InspectionOperationRow: Int {
    case Action = 0
    
    static let count: Int = {
        return 1
    }()
}