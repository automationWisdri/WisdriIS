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
    @IBOutlet weak var planDescriptionTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var estimatedDateLabel: UILabel!
    @IBOutlet weak var relevantUserTextView: TaskTextView!
    @IBOutlet weak var relevantUserTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var indexLabel: UILabel!
    
    private let taskMediaCellID = "TaskMediaCell"
    
    // 方案附属文件
    private var wisFileInfos = [WISFileInfo]()
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, wisFileInfos: [WISFileInfo], index: Int) -> Void)?
    
    static let planTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.mainScreen().bounds.width - 30
        return maxWidth
    }()
    
    static let relevantUserTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.mainScreen().bounds.width - 54
        return maxWidth
    }()
    
    class func instanceFromNib() -> TaskPlanCell {
        return UINib(nibName: "TaskPlanCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TaskPlanCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        planDescriptionTextView.textContainer.lineFragmentPadding = 0
        planDescriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 为了保证文字和图标对其，增加 1 pixel 顶部缩进
        relevantUserTextView.textContainer.lineFragmentPadding = 0
        relevantUserTextView.textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
            
        planImageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 15)
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
    
    override func prepareForReuse() {
        wisFileInfos.removeAll()
    }
    
    func bind(taskPlan: WISMaintenancePlan, index: Int) {
        
        // Bind Data
        self.indexLabel.text = "#\(index)"
        self.planDescriptionTextView.text = taskPlan.planDescription
        self.estimatedDateLabel.text = taskPlan.estimatedEndingTime.toDateStringWithSeparator("-") + " 前完成"
        self.relevantUserTextView.text = WISUserDefaults.getRelevantUserText(taskPlan.participants)
        
        for item : AnyObject in taskPlan.imagesInfo.allKeys {
            self.wisFileInfos.append(taskPlan.imagesInfo.objectForKey(item) as! WISFileInfo)
        }
        
//        dispatch_async(dispatch_get_main_queue()) {
//            self.planImageCollectionView.reloadData()
//        }
        
        // Make UI
        if wisFileInfos.count != 0 {
            planImageCollectionView.hidden = false
        } else {
            planImageCollectionView.hidden = true
        }

        self.planDescriptionTextHeightConstraint.constant = calHeightOfPlanTextView(text: planDescriptionTextView.text)
        
        self.relevantUserTextHeightConstraint.constant = calHeightOfUserTextView(text: relevantUserTextView.text)
    }
    
    func calHeightOfCell(taskPlan: WISMaintenancePlan) -> CGFloat {
        
        var heightOfCell: CGFloat
        
        let planDescriptionTextHeight = calHeightOfPlanTextView(text: taskPlan.planDescription)
        
        let relevantUserText = WISUserDefaults.getRelevantUserText(taskPlan.participants)
        let relevantUserTextHeight = calHeightOfUserTextView(text: relevantUserText)
        
        if taskPlan.imagesInfo.count != 0 {
            heightOfCell = 162 + planDescriptionTextHeight + relevantUserTextHeight
        } else {
            heightOfCell = 74 +  planDescriptionTextHeight + relevantUserTextHeight
        }
        
        return heightOfCell
    }
    
    private func calHeightOfPlanTextView(text text: String) -> CGFloat {
        
        let rect = text.boundingRectWithSize(CGSize(width: TaskPlanCell.planTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: WISConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        return ceil(rect.height)
    }
    
    private func calHeightOfUserTextView(text text: String) -> CGFloat {
        
        let rect = text.boundingRectWithSize(CGSize(width: TaskPlanCell.relevantUserTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: WISConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        return ceil(rect.height) + 1
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