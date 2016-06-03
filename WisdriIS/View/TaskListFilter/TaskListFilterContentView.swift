//
//  TaskListFilterView.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 6/1/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskListFilterContentView: UIView {
    
    let TaskListFilterGroupContentViewID = "TaskListFilterGroupContentView"
    let TaskListFilterButtonViewID = "TaskListFilterButtonView"
    
    var taskListFilterWrapperView: UIScrollView!
    var taskListFilterGroupContentView: TaskListFilterGroupContentView!
    
    var taskListFilterButtonView: UIView!
    
    weak var parentViewController: UIViewController!
    var delegate: TaskListFilterContentViewDelegate?
    
    var currentGroupSelection: TaskListGroupType!
    
    init(frame: CGRect, parentViewController: UIViewController!, initialGroupSelection: TaskListGroupType) {
        super.init(frame: CGRectZero)
        
        self.parentViewController = parentViewController
        self.currentGroupSelection = initialGroupSelection
        
        self.prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareView() {
        // Constants for initializing
        let taskListFilterButtonViewHeight: CGFloat = 50
        
        let mainScreenBound = UIScreen.mainScreen().applicationFrame
        let navigationBarHeight = self.parentViewController.navigationController?.navigationBar.bounds.height
        let tabBarHeight = self.parentViewController.tabBarController?.tabBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        let filterContentViewMaxHeight = mainScreenBound.height - (statusBarHeight + navigationBarHeight! + tabBarHeight!) - taskListFilterButtonViewHeight
        let itemGapHeight: CGFloat = 2
        
        let refFrame = CGRectMake(0.0,
                                  statusBarHeight + navigationBarHeight!,
                                  mainScreenBound.width,
                                  filterContentViewMaxHeight)
        
        //
        // initial contents - in wrapper view
        //
        // ** Group selection
        if self.taskListFilterGroupContentView == nil {
            self.taskListFilterGroupContentView = NSBundle.mainBundle().loadNibNamed(self.TaskListFilterGroupContentViewID, owner: self, options: nil).last as! TaskListFilterGroupContentView
        }
        self.taskListFilterGroupContentView!.frame = CGRectMake(0.0, 0.0, refFrame.size.width, self.taskListFilterGroupContentView!.viewHeight)
        self.taskListFilterGroupContentView.bindData(currentGroupSelection)
        
        // ** content wrapper
        let contentHeight = self.taskListFilterGroupContentView.frame.origin.x + self.taskListFilterGroupContentView.bounds.size.height
        let wrapperHeight = min(contentHeight, filterContentViewMaxHeight)
        
        if self.taskListFilterWrapperView == nil {
            self.taskListFilterWrapperView = UIScrollView.init(frame: CGRectZero)
        }
        self.taskListFilterWrapperView.frame = CGRectMake(refFrame.origin.x, refFrame.origin.y, refFrame.size.width, wrapperHeight)
        self.taskListFilterWrapperView.scrollEnabled = true
        self.taskListFilterWrapperView.bounces = true
        self.taskListFilterWrapperView.indicatorStyle = .Default
        self.taskListFilterWrapperView.showsVerticalScrollIndicator = true
        self.taskListFilterWrapperView.backgroundColor = UIColor.whiteColor()
        self.taskListFilterWrapperView.contentSize = CGSize(width: refFrame.width, height: contentHeight + 2)
        
        //
        // initial button view
        //
        if self.taskListFilterButtonView == nil {
            self.taskListFilterButtonView = UIView(frame: CGRectZero)
        }
        let contentWrapperFrame = self.taskListFilterWrapperView.frame
        let buttonViewX = contentWrapperFrame.origin.x
        let buttonViewY = contentWrapperFrame.origin.y + contentWrapperFrame.size.height + itemGapHeight
        
        self.taskListFilterButtonView.frame = CGRectMake(buttonViewX, buttonViewY, contentWrapperFrame.size.width, taskListFilterButtonViewHeight)
        
        
        let okButton = UIButton(type: .System)
        okButton.frame = CGRectMake(self.taskListFilterButtonView!.frame.size.width / 2, 0.0, self.taskListFilterButtonView!.frame.size.width / 2, taskListFilterButtonViewHeight)
        okButton.backgroundColor = UIColor.redColor()
        okButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        okButton.setTitle(NSLocalizedString("OK", comment: ""), forState: .Normal)
        okButton.titleLabel?.font = UIFont.systemFontOfSize(17)
        // okButton.autoresizingMask = .FlexibleWidth
        okButton.tag = ButtonType.OK.rawValue
        okButton.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        let cancelButton = UIButton(type: .System)
        cancelButton.frame = CGRectMake(0.0, 0.0, self.taskListFilterButtonView!.frame.size.width / 2, taskListFilterButtonViewHeight)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: .Normal)
        // cancelButton.titleLabel?.adjustsFontSizeToFitWidth = false
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(17)
        // cancelButton.autoresizingMask = .FlexibleWidth
        cancelButton.tag = ButtonType.Cancel.rawValue
        cancelButton.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        //
        // initial content view
        //
        self.frame = CGRectMake(0.0, 0.0, refFrame.size.width, (self.taskListFilterWrapperView?.frame.size.height)! + itemGapHeight + taskListFilterButtonViewHeight + statusBarHeight + navigationBarHeight!)
        self.backgroundColor = UIColor.whiteColor()
        
        // add views
        if self.taskListFilterWrapperView?.subviews.count > 0 {
            self.taskListFilterWrapperView?.removeAllSubviews()
        }
        
        if self.taskListFilterButtonView?.subviews.count > 0 {
            self.taskListFilterButtonView?.removeAllSubviews()
        }
        
        if self.subviews.count > 0 {
            self.removeAllSubviews()
        }
        
        self.addSubview(self.taskListFilterWrapperView!)
        self.addSubview(self.taskListFilterButtonView!)
        
        self.taskListFilterWrapperView!.addSubview(self.taskListFilterGroupContentView!)
        self.taskListFilterButtonView?.addSubview(okButton)
        self.taskListFilterButtonView?.addSubview(cancelButton)
        
        self.layoutIfNeeded()
    }
    
    func buttonPressed(sender: UIButton) {
        guard self.delegate != nil else {
            return
        }
        
        let buttonType: ButtonType = ButtonType(rawValue: (sender as UIButton).tag)!
        
        switch buttonType {
        case .OK:
            let groupType = TaskListGroupType(rawValue: self.taskListFilterGroupContentView.currentSelectedIndexPath.row)!
            self.taskListFilterGroupContentView.currentSelectedIndexPath = NSIndexPath(forRow: groupType.rawValue, inSection: 0)
            self.currentGroupSelection = groupType
            self.delegate?.taskListFilterContentViewConfirmed(groupType)
            
        case .Cancel:
            self.delegate?.taskListFilterContentViewCancelled()
        }
    }
    
    enum ButtonType: Int {
        case OK = 0
        case Cancel = 1
    }
}

protocol TaskListFilterContentViewDelegate {
    func taskListFilterContentViewConfirmed(groupType: TaskListGroupType) -> Void
    func taskListFilterContentViewCancelled() -> Void
}
