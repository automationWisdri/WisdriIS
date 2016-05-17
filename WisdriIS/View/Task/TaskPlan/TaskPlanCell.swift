//
//  TaskPlanCell.swift
//  WisdriIS
//
//  Created by Allen on 4/2/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskPlanCell: UITableViewCell {

    @IBOutlet weak var planImageCollectionView: UICollectionView!
    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var planDescriptionTextView: TaskTextView!
    @IBOutlet weak var estimatedDateLabel: UILabel!
    @IBOutlet weak var relevantUserTextView: TaskTextView!
    
    let taskMediaCellID = "TaskMediaCell"
    
    // 方案附属文件
    private var wisFileInfos = [WISFileInfo]()
    
    private var images = [UIImage]() {
        didSet {
            planImageCollectionView.reloadData()
        }
    }
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, wisFileInfos: [WISFileInfo], index: Int) -> Void)?
    
    class func instanceFromNib() -> TaskPlanCell {
        return UINib(nibName: "TaskPlanCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TaskPlanCell
    }
    
    static let textViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.mainScreen().bounds.width - 27
//        print(maxWidth)
        return maxWidth
    }()

    func heightOfCell(plan: String, user: String) -> CGFloat {
        
        let plan: String = plan
        let user: String = user
        
        let planDescriptionRect = plan.boundingRectWithSize(CGSize(width: TaskPlanCell.textViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        let relevantUserRect = user.boundingRectWithSize(CGSize(width: TaskPlanCell.textViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.TaskDescriptionCell.textAttributes, context: nil)

        let height: CGFloat = 142 + ceil(planDescriptionRect.height) + ceil(relevantUserRect.height)
        
        return ceil(height)
    }
    
    private func calHeightOfPlanDescriptionTextView() {
        
        let rect = planDescriptionTextView.text.boundingRectWithSize(CGSize(width: TaskPlanCell.textViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        planDescriptionTextView.frame.size.height = ceil(rect.height)
    }

    func getImagesFileInfo(wisFileInfos: [WISFileInfo]) {
        if wisFileInfos.count == 0 {
            print("方案没有附属图片")
            return
        } else {
//            print("方案有 \(wisFileInfos.count) 张图片")
            self.wisFileInfos = wisFileInfos
            planImageCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        planDescriptionTextView.textContainer.lineFragmentPadding = 0
        planDescriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        relevantUserTextView.textContainer.lineFragmentPadding = 0
        relevantUserTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        planImageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 15)
        planImageCollectionView.showsHorizontalScrollIndicator = false
        planImageCollectionView.backgroundColor = UIColor.clearColor()
        planImageCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        planImageCollectionView.dataSource = self
        planImageCollectionView.delegate = self
//        print("CollectionView 方案有 \(self.wisFileInfos.count) 张图片")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension TaskPlanCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, wisFileInfos: wisFileInfos, index: indexPath.item)
    }
}