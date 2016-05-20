//
//  TaskDescriptionCell.swift
//  WisdriIS
//
//  Created by Allen on 3/7/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskDescriptionCell: UITableViewCell {

    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var taskDescriptionTextView: TaskTextView!
    @IBOutlet weak var taskImageCollectionView: UICollectionView!
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var taskDescriptionTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sectionLabelWidthConstraint: NSLayoutConstraint!
    
    private let taskMediaCellID = "TaskMediaCell"
    
    private let sectionLabelTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
    
    private var wisFileInfos = [WISFileInfo]()
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, wisFileInfos: [WISFileInfo], index: Int) -> Void)?

    static let taskDescriptionTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.mainScreen().bounds.width - (20 + 10)
        return maxWidth
    }()
    
    class func instanceFromNib() -> TaskDescriptionCell {
        return UINib(nibName: "TaskDescriptionCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TaskDescriptionCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        taskDescriptionTextView.textContainer.lineFragmentPadding = 0
        taskDescriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        taskImageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 15)
        taskImageCollectionView.showsHorizontalScrollIndicator = false
        taskImageCollectionView.backgroundColor = UIColor.clearColor()
        taskImageCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        taskImageCollectionView.dataSource = self
        taskImageCollectionView.delegate = self

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        wisFileInfos.removeAll()
    }
    
    func bind(wisTask: WISMaintenanceTask) {
        self.sectionNameLabel.text = wisTask.processSegmentName
        self.taskDescriptionTextView.text = wisTask.taskApplicationContent
        self.taskTimeLabel.text = WISConfig.DATE.stringFromDate(wisTask.createdDateTime) + " 报修"
        
        for item : AnyObject in wisTask.imagesInfo.allKeys {
            self.wisFileInfos.append(wisTask.imagesInfo.objectForKey(item) as! WISFileInfo)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.taskImageCollectionView.reloadData()
        }
        
        // Make UI
        if wisTask.imagesInfo.count == 0 {
            taskImageCollectionView.hidden = true
        } else {
            taskImageCollectionView.hidden = false
        }
        
        self.taskDescriptionTextHeightConstraint.constant = calHeightOfTaskDescriptionTextView(text: self.taskDescriptionTextView.text)
        self.sectionLabelWidthConstraint.constant = ceil(sectionNameLabel.text!.boundingRectWithSize(CGSize(width: CGFloat(FLT_MAX), height: 18), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: sectionLabelTextAttributes, context: nil).width)
    }
    
    func calHeightOfCell(wisTask: WISMaintenanceTask) -> CGFloat {
        
        var heightOfCell: CGFloat
        
        let taskTextHeight = calHeightOfTaskDescriptionTextView(text: wisTask.taskApplicationContent)
        
        if wisTask.imagesInfo.count == 0 {
            heightOfCell = 73 + taskTextHeight
        } else {
            heightOfCell = 161 + taskTextHeight
        }
        
        return heightOfCell
    }
    
    private func calHeightOfTaskDescriptionTextView(text text: String) -> CGFloat {
        
        let rect = text.boundingRectWithSize(CGSize(width: TaskDescriptionCell.taskDescriptionTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: WISConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        return ceil(rect.height)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension TaskDescriptionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("DescriptionCell numberOfItems 中有 \(fileInfo.count) 张图片")
        return wisFileInfos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell
        
        if wisFileInfos.count != 0 {
//            print("DescriptionCell cellForItem 中有 \(fileInfo.count) 张图片")
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