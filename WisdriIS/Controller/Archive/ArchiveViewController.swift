//
//  RemarkViewController.swift
//  WisdriIS
//
//  Created by Allen on 4/23/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD

class ArchiveViewController: UIViewController {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var archiveScrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    
    private let archiveAboutThisTask = "请填入有关本维保任务的关键词及归档备注"
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            postButton.enabled = newValue
            
            if !newValue && isNeverInputMessage && !messageTextView.isFirstResponder() {
                messageTextView.text = archiveAboutThisTask
            }
            
            messageTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(ArchiveViewController.post(_:)))
        button.enabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = NSLocalizedString("Archive", comment: "")
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        view.userInteractionEnabled = true
        
        navigationItem.rightBarButtonItem = postButton
        
        isDirty = false
        
//        remarkScrollView.delegate = self

        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTextView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        // 归档描述字段的长度控制
        let messageLength = (messageTextView.text as NSString).length
        
        guard messageLength <= WISConfig.maxTaskTextLength else {
            let message = String(format: NSLocalizedString("Archive info is too long!\nUp to %d letters.", comment: ""), WISConfig.maxTaskTextLength)
            WISAlert.alertSorry(message: message, inViewController: self)
            return
        }
        
        SVProgressHUD.showWithStatus("正在提交")
        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: messageTextView.text, operationType: MaintenanceTaskOperationType.Archive, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
            if completedWithNoError {
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus("归档成功")
//                self.navigationController?.popViewControllerAnimated(true)
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            } else {
                
                WISConfig.errorCode(error)
            }
        })

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        restoreTextViewPlaceHolder()
    }
    
    private func restoreTextViewPlaceHolder() {
        messageTextView.resignFirstResponder()
        if !isDirty && isNeverInputMessage {
            messageTextView.text = archiveAboutThisTask
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

extension ArchiveViewController: UITextViewDelegate {
    
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

extension ArchiveViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
//        messageTextView.resignFirstResponder()
        restoreTextViewPlaceHolder()
    }
}