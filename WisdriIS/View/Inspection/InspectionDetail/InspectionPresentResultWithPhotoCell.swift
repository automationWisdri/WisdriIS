//
//  InspectionShowResultWithPhotoCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 5/22/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionPresentResultWithPhotoCell:InspectionDetailViewBaseCell {
    private static let cellWithImageHeight: CGFloat = 180.0
    private static let cellWithNoImageHeight: CGFloat = 100.0
    
    @IBOutlet weak var inspectionResultTitleLabel: UILabel!
    @IBOutlet weak var inspectionResultLabel: UILabel!
    @IBOutlet weak var inspectionImagesTitleLabel: UILabel!
    @IBOutlet weak var inspectionImagesCollectionView: UICollectionView!
    @IBOutlet weak var inspectionFinishedTimeLabel: UILabel!
    
    let taskMediaCellID = "TaskMediaCell"
    
    private var inspectionImageFileInfos = [WISFileInfo]()
    
    private var images = [UIImage]() {
        didSet {
            inspectionImagesCollectionView.reloadData()
        }
    }
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, wisFileInfos: [WISFileInfo], index: Int) -> Void)?
    
    class func instanceFromNib() -> InspectionPresentResultWithPhotoCell {
        return UINib(nibName: "InspectionPresentResultWithPhotoCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! InspectionPresentResultWithPhotoCell
    }
    
    class func calCellHeight(model: WISInspectionTask) -> CGFloat {
        return model.imagesInfo.count > 0 ? InspectionPresentResultWithPhotoCell.cellWithImageHeight : InspectionPresentResultWithPhotoCell.cellWithNoImageHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        inspectionImagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 15)
        inspectionImagesCollectionView.showsHorizontalScrollIndicator = false
        inspectionImagesCollectionView.backgroundColor = UIColor.clearColor()
        inspectionImagesCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        inspectionImagesCollectionView.dataSource = self
        inspectionImagesCollectionView.delegate = self
        inspectionImagesCollectionView.scrollsToTop = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask) {
        self.inspectionResultTitleLabel.text = NSLocalizedString("Inspection Result", comment:"") //+ ": "
        
        switch model.inspectionResult {
        case .DeviceNormal:
            inspectionResultLabel.text = NSLocalizedString("Normal", comment: "")
            inspectionResultLabel.textColor = UIColor.blackColor()
        case .DeviceFaultForHandle:
            inspectionResultLabel.text = NSLocalizedString("Fault for Handle", comment: "")
            inspectionResultLabel.textColor = UIColor.redColor()
        case .NotSelected:
            inspectionResultLabel.text = NSLocalizedString("None", comment: "")
            inspectionResultLabel.textColor = UIColor.blackColor()
        }
        
        if model.imagesInfo.count == 0 {
            print("No image")
            self.inspectionImagesCollectionView.hidden = true
            self.inspectionImagesTitleLabel.text = NSLocalizedString("No image uploaded in this inspection task", comment:"")
            // self.inspectionImagesTitleLabel.font = UIFont.systemFontOfSize(15.0)
        } else {
            print("Totally \(model.imagesInfo.count) image(s)")
            self.inspectionImageFileInfos = model.imagesInfo.allValues as! [WISFileInfo]
            self.inspectionImagesCollectionView.hidden = false
            self.inspectionImagesTitleLabel.text = String.localizedStringWithFormat("Totally %d images uploaded in this inspection task", model.imagesInfo.count)
            self.inspectionImagesTitleLabel.font = UIFont.systemFontOfSize(17.0)
            
            inspectionImagesCollectionView.reloadData()
        }
        
        self.inspectionFinishedTimeLabel.text = model.inspectionFinishedTime.toDateTimeString() + " " + NSLocalizedString("Finished", comment: "")
    }
}


extension InspectionPresentResultWithPhotoCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inspectionImageFileInfos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell
        
        if self.inspectionImageFileInfos.count != 0 {
            cell.configureWithFileInfo(self.inspectionImageFileInfos[indexPath.item])
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
        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, wisFileInfos: self.inspectionImageFileInfos, index: indexPath.item)
    }
    
}
