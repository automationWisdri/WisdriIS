//
//  InspectionPickPhotoCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
//import CoreLocation
import MobileCoreServices
import Photos
import Proposer
//import RealmSwift
//import Kingfisher
import MapKit
//import SVProgressHUD


class InspectionPickPhotoCell : UITableViewCell {
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    weak var superViewController:UIViewController?
    
    private var imageAssets: [PHAsset] = []
    
    var mediaImages = [UIImage]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.mediaCollectionView.reloadData()
            }
        }
    }
    
    let imageCountUpLimit = PickPhotosViewController.imagePickCountLimit
    
    private var imagesDictionary = Dictionary<String, UIImage>()
    
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
                
                //                YepHUD.showActivityIndicator()
                
                //            case .Failed(let message):
                //                YepHUD.hideActivityIndicator()
                //                postButton.enabled = true
                
                //                if presentingViewController != nil {
                //                    WISAlert.alertSorry(message: message, inViewController: self)
                //                } else {
                //                    feedsViewController?.handleUploadingErrorMessage(message)
                //                }
                break
                
            case .Success:
                //                YepHUD.hideActivityIndicator()
                break
                
            default:
                break
            }
        }
    }
    
    private let taskMediaAddCellID = "TaskMediaAddCell"
    private let taskMediaCellID = "TaskMediaCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.registerNib(UINib(nibName: taskMediaAddCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaAddCellID)
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.hidden = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


extension InspectionPickPhotoCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return mediaImages.count
        case 1: return 1
        default: return 0
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
            collectionView.deleteItemsAtIndexPaths([indexPath])
            
        case 1:
            if mediaImages.count >= imageCountUpLimit {
                WISAlert.alertSorry(message: NSLocalizedString("Task can only has \(imageCountUpLimit) photos."), inViewController: self.superViewController)
                return
            }
            let pickAlertController = UIAlertController(title: NSLocalizedString("Choose Source"), message: nil, preferredStyle: .ActionSheet)
            
            let cameraAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Camera"), style: .Default) { action -> Void in
                proposeToAccess(.Camera,
                agreed: { [weak self] in
                    guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
                        self?.superViewController!.alertCanNotOpenCamera()
                        return
                    }
                    
                    if let strongSelf = self {
                        let viewController = strongSelf.superViewController as! InspectionDetailViewController
                        viewController.imagePicker.sourceType = .Camera
                        viewController.presentViewController(viewController.imagePicker, animated: true, completion: nil)
                    }
                    
                }, rejected: { [weak self] in
                    self!.superViewController!.alertCanNotOpenCamera()
                })
            }
            pickAlertController.addAction(cameraAction)
            
            let albumAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Albums"), style: .Default) { [weak self] action -> Void in
                proposeToAccess(.Photos,
                agreed: { [weak self] in
                    let board = UIStoryboard.init(name: "PickPhotos", bundle: NSBundle.mainBundle())
                    let viewController = board.instantiateViewControllerWithIdentifier("PickPhotosViewController") as! PickPhotosViewController
                    viewController.pickedImageSet = Set(self!.imageAssets)
                    viewController.imageLimit = self!.mediaImages.count
                    viewController.completion = { [weak self] images, imageAssets in
                        for image in images {
                            self?.mediaImages.append(image)
                            self?.imagesDictionary["task_image" + String(image.hash)] = image
                            print(self?.imagesDictionary["task_image" + String(image.hash)])
                        }
                    }
                    
                    let masterViewController = self!.superViewController as! InspectionDetailViewController
                    
                    masterViewController.navigationController?.pushViewController(viewController, animated: true)
                    
                }, rejected: { [weak self] in
                    self!.superViewController!.alertCanNotAccessCameraRoll()
                })
            }
            pickAlertController.addAction(albumAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { action -> Void in
                
            }
            pickAlertController.addAction(cancelAction)
            
            superViewController!.presentViewController(pickAlertController, animated: true, completion: nil)
            
        default:
            break
        }
    }
}



