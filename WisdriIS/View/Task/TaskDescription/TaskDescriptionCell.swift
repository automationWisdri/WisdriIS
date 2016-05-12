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
    @IBOutlet weak var taskDescriptionTextView: FeedTextView!
    @IBOutlet weak var taskImageCollectionView: UICollectionView!
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var mediaView: TaskMediaView!
    
    let taskMediaCellID = "TaskMediaCell"
    
//    private let images: [UIImage] = [UIImage(named: "32.jpg")!, UIImage(named: "profile-bg.jpg")!, UIImage(named: "login-bg-iphone-6.jpg")!, UIImage(named: "Cover3")!]
//    private var images = [UIImage]() {
//        didSet {
//            taskImageCollectionView.reloadData()
//        }
//    }
    
    private var fileInfo = [WISFileInfo]()
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, wisFileInfos: [WISFileInfo], index: Int) -> Void)?

    
    static let taskDescriptionTextViewMaxWidth: CGFloat = {
//        let maxWidth = UIScreen.mainScreen().bounds.width - (15 + 40 + 10 + 15)
        let maxWidth = UIScreen.mainScreen().bounds.width - 27
//        print(maxWidth)
        return maxWidth
    }()
    
    class func instanceFromNib() -> TaskDescriptionCell {
        return UINib(nibName: "TaskDescriptionCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TaskDescriptionCell
    }
    
    func heightOfCell(body: String) -> CGFloat {
        
        let body: String = body
        
        let rect = body.boundingRectWithSize(CGSize(width: TaskDescriptionCell.taskDescriptionTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.TaskDescriptionCell.textAttributes, context: nil)
//        print(rect.height)
        let height: CGFloat = 149 + ceil(rect.height)
        
        return ceil(height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        taskImageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 15)
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
    
    private func calHeightOfTaskDescriptionTextView() {
        
        let rect = taskDescriptionTextView.text.boundingRectWithSize(CGSize(width: TaskDescriptionCell.taskDescriptionTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        taskDescriptionTextView.frame.size.height = ceil(rect.height)
    }

    func getImagesFileInfo(fileInfo: [WISFileInfo]) {
        if fileInfo.count == 0 {
            print("任务没有附属图片")
            return
        } else {
            self.fileInfo = fileInfo
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension TaskDescriptionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("DescriptionCell numberOfItems 中有 \(fileInfo.count) 张图片")
        return fileInfo.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell
        
        if fileInfo.count != 0 {
//            print("DescriptionCell cellForItem 中有 \(fileInfo.count) 张图片")
            cell.configureWithFileInfo(fileInfo[indexPath.item])
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
        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, wisFileInfos: fileInfo, index: indexPath.item)

    }
}