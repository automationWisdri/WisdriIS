//
//  RemarkViewController.swift
//  WisdriIS
//
//  Created by Allen on 4/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

class RemarkViewController: UIViewController {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var remarkScrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    
    private let remarkAboutThisTask = NSLocalizedString("Remark about this maintenance service")
    private let disputeInfoAboutThisTask = NSLocalizedString("Note about this dispute situation")
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            postButton.enabled = newValue
            
            if !newValue && isNeverInputMessage && !messageTextView.isFirstResponder() {
                switch segueIdentifier! {
                    
                case "remarkOperation":
                    messageTextView.text = remarkAboutThisTask
                    
                case "startDisputeOperation":
                    messageTextView.text = disputeInfoAboutThisTask
                    
                default:
                    break
                }
            }
            
            messageTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(RemarkViewController.post(_:)))
        button.enabled = false
        return button
    }()
    
    // 导入页面的 Segue Identifier
    var segueIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch segueIdentifier! {
            
        case "remarkOperation":
            title = NSLocalizedString("Remark", comment: "")
            
        case "startDisputeOperation":
            title = NSLocalizedString("Dispute", comment: "")
            
        default:
            break
        }

        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        view.userInteractionEnabled = true
        
        navigationItem.rightBarButtonItem = postButton
        
        isDirty = false

        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTextView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        // 任务描述字段的长度控制
        let messageLength = (messageTextView.text as NSString).length
        
        guard messageLength <= WISConfig.maxTaskTextLength else {
            let message = String(format: NSLocalizedString("Info is too long!\nUp to %d letters.", comment: ""), WISConfig.maxTaskTextLength)
            WISAlert.alertSorry(message: message, inViewController: self)
            return
        }
        
        SVProgressHUD.showWithStatus(WISConfig.HUDString.commiting)
        switch segueIdentifier! {
            
        case "remarkOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: messageTextView.text, operationType: MaintenanceTaskOperationType.Remark, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.showSuccessWithStatus("备注成功")
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
            
        case "startDisputeOperation":
            WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: messageTextView.text, operationType: MaintenanceTaskOperationType.StartDisputeProcedure, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
                if completedWithNoError {
                    SVProgressHUD.showSuccessWithStatus("提交成功\n任务已归档")
                    self.navigationController?.popViewControllerAnimated(true)
                    
                } else {
                    
                    WISConfig.errorCode(error)
                }
            })
            
        default:
            break
        }
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        restoreTextViewPlaceHolder()
    }
    
    private func restoreTextViewPlaceHolder() {
        messageTextView.resignFirstResponder()
        if !isDirty && isNeverInputMessage {
            
            switch segueIdentifier! {
                
            case "remarkOperation":
                messageTextView.text = remarkAboutThisTask
                
            case "startDisputeOperation":
                messageTextView.text = disputeInfoAboutThisTask
                
            default:
                break
            }
            messageTextView.textColor = UIColor.lightGrayColor()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITextViewDelegate

extension RemarkViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if !isDirty {
            textView.text = ""
        }
        
        isNeverInputMessage = false
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        isNeverInputMessage = NSString(string: textView.text).length == 0
        isDirty = NSString(string: textView.text).length > 0
    }
    
}

// MARK: - UIScrollViewDelegate

extension RemarkViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {

        restoreTextViewPlaceHolder()
    }
}
