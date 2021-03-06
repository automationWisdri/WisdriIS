//
//  OperationTypesView.swift
//  WisdriIS
//
//  Created by Allen on 3/21/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class OperationTypeCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var colorTitleLabelTextColor: UIColor = UIColor.wisTintColor() {
        willSet {
            colorTitleLabel.textColor = newValue
        }
    }

    enum FontStyle {
        case Light
        case Regular
    }

    var colorTitleLabelFontStyle: FontStyle = .Light {
        willSet {
            switch newValue {
            case .Light:
                if #available(iOS 8.2, *) {
                    colorTitleLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
                } else {
                    colorTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)!
                }
            case .Regular:
                colorTitleLabel.font = UIFont.systemFontOfSize(18)
            }
        }
    }

    func makeUI() {
        contentView.addSubview(colorTitleLabel)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerY = NSLayoutConstraint(item: colorTitleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: colorTitleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)

        NSLayoutConstraint.activateConstraints([centerY, centerX])
    }
}


class OperationTypesView: UIView {
    // var validOperations = currentTask!.validOperations

    var totalHeight: CGFloat? // = 60 * CGFloat(currentTaskOperations.count)

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }()

    lazy var tableView: UITableView = {
        let view = UITableView()

        view.dataSource = self
        view.delegate = self
        view.rowHeight = 60
        view.scrollEnabled = false

        view.registerClass(OperationTypeCell.self, forCellReuseIdentifier: "OperationTypeCell")
//        view.registerClass(ConversationMoreColorTitleCell.self, forCellReuseIdentifier: "ConversationMoreColorTitleCell")
        return view
    }()

    var repealOperation: (() -> Void)?
    var acceptOperation: (() -> Void)?
    var passOperation: (() -> Void)?
//    var refuseOperation: (() -> Void)?
    var submitPlanOperation: (() -> Void)?
    var submitQuickPlanOperation: (() -> Void)?
    var completeOperation: (() -> Void)?
    var approveOperation: (() -> Void)?
    var recheckOperation: (() -> Void)?
    var rejectOperation: (() -> Void)?
    var redoOperation: (() -> Void)?
    var confirmOperation: (() -> Void)?
    var archiveOperation: (() -> Void)?
    var acceptPassOperation: (() -> Void)?
    var refusePassOperation: (() -> Void)?
    var applyRecheckOperation: (() -> Void)?
    var modifyPlanOperation: (() -> Void)?
    var remarkOperation: (() -> Void)?
    var assignOperation: (() -> Void)?
    var acceptAssignedOperation: (() -> Void)?
    var declineOperation: (() -> Void)?
    var startDisputeOperation: (() -> Void)?
    var continueOperation: (() -> Void)?

    var tableViewBottomConstraint: NSLayoutConstraint?

    func showInView(view: UIView) {

        totalHeight = 60 * CGFloat(currentTaskOperations.count)
        
        frame = view.bounds
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
        }
        
        view.addSubview(self)

        layoutIfNeeded()

        containerView.alpha = 1

        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {[weak self]  _ in
            self?.containerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)

        }, completion: { _ in
        })

        UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: {[weak self]  _ in
            self?.tableViewBottomConstraint?.constant = 0

            self?.layoutIfNeeded()

        }, completion: { _ in
        })
    }

    func hide() {

        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {[weak self]  _ in

            if let strongSelf = self {
                strongSelf.tableViewBottomConstraint?.constant = strongSelf.totalHeight!
            }

            self?.layoutIfNeeded()

        }, completion: { _ in
        })

        UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: {[weak self]  _ in
            self?.containerView.backgroundColor = UIColor.clearColor()

        }, completion: {[weak self]  _ in
            self?.removeFromSuperview()
        })
    }

    func hideAndDo(afterHideAction: (() -> Void)?) {

        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {[weak self]  _ in
            self?.containerView.alpha = 0

            if let strongSelf = self {
                strongSelf.tableViewBottomConstraint?.constant = strongSelf.totalHeight!
            }
            
            self?.layoutIfNeeded()

        }, completion: {[weak self]  finished in
            self?.removeFromSuperview()
        })

        delay(0.1) {
            afterHideAction?()
        }
    }

    /// because task states may change when taskDetailViewController reappear after operations, you have to update pop up menu all the time
    /// 2016.05.14
    // var isFirstTimeBeenAddAsSubview = true

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
//        if isFirstTimeBeenAddAsSubview {
//            isFirstTimeBeenAddAsSubview = false

        makeUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(OperationTypesView.hide))
        containerView.addGestureRecognizer(tap)
        
        tap.cancelsTouchesInView = true
        tap.delegate = self
        
//         }
    }

    func makeUI() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let viewsDictionary: [String: AnyObject] = [
            "containerView": containerView,
            "tableView": tableView,
        ]

        // layout for containerView

        let containerViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let containerViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

        NSLayoutConstraint.activateConstraints(containerViewConstraintsH)
        NSLayoutConstraint.activateConstraints(containerViewConstraintsV)

        // layout for tableView

        let tableViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: [], metrics: nil, views: viewsDictionary)

        let tableViewBottomConstraint = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: self.totalHeight!)

        self.tableViewBottomConstraint = tableViewBottomConstraint

        let tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.totalHeight!)

        NSLayoutConstraint.activateConstraints(tableViewConstraintsH)
        NSLayoutConstraint.activateConstraints([tableViewBottomConstraint, tableViewHeightConstraint])
    }
}

// MARK: - UIGestureRecognizerDelegate

extension OperationTypesView: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {

        if touch.view != containerView {
            return false
        }

        return true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension OperationTypesView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTaskOperations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let operationType = MaintenanceTaskOperationType(rawValue: Int(currentTaskOperations[indexPath.row].operationType)!) else {
            return UITableViewCell()
        }
        
//        switch currentTaskOperations[indexPath.row].operationType {

        switch operationType {

        case .Cancel:

//            let cell = tableView.dequeueReusableCellWithIdentifier("ConversationMoreColorTitleCell") as! ConversationMoreColorTitleCell
            let cell = tableView.dequeueReusableCellWithIdentifier("OperationTypeCell") as! OperationTypeCell
            cell.colorTitleLabel.text = currentTaskOperations[indexPath.row].operationName
            cell.colorTitleLabelTextColor = UIColor.wisTintColor()
            cell.colorTitleLabelFontStyle = .Light

            return cell

        default:

            let cell = tableView.dequeueReusableCellWithIdentifier("OperationTypeCell") as! OperationTypeCell
            cell.colorTitleLabel.text = currentTaskOperations[indexPath.row].operationName
            cell.colorTitleLabelTextColor = UIColor.wisTintColor()
            cell.colorTitleLabelFontStyle = .Light

            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if let row = MaintenanceTaskOperationType(rawValue: Int(currentTaskOperations[indexPath.row].operationType)!) {

            switch row {
                
            case .Archive:
                hide()
                archiveOperation?()
                
            case .Cancel:
                hide()
                repealOperation?()

            case .Approve:
                hide()
                approveOperation?()
                
            case .Reject:
                hide()
                rejectOperation?()
                
            case .AcceptMaintenanceTask:
                hide()
                acceptOperation?()
                
            case .PassOn:
                hide()
                passOperation?()
                
            case .SubmitMaintenancePlan:
                hide()
                submitPlanOperation?()
                
            case .StartFastProcedure:
                hide()
                submitQuickPlanOperation?()
                
            case .AcceptPassOnTask:
                hide()
                acceptPassOperation?()
                
            case .RefuseToReceiveTask:
                hide()
                refusePassOperation?()
                
            case .ApplyForRecheck:
                hide()
                recheckOperation?()
                
            case .TaskComplete:
                hide()
                completeOperation?()
                
            case .Confirm:
                hide()
                confirmOperation?()
                
            case .Modify:
                hide()
                modifyPlanOperation?()
                
            case .Remark:
                hide()
                remarkOperation?()
                
            case .Assign:
                hide()
                assignOperation?()
                
            case .AcceptAssignedPassOnTask:
                hide()
                acceptAssignedOperation?()
                
            case .DeclineToConfirm:
                hide()
                declineOperation?()
                
            case .StartDisputeProcedure:
                hide()
                startDisputeOperation?()
                
            case .Continue:
                hide()
                continueOperation?()

            default:
                hide()
            }
        }
    }
}

