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
    
    private let remarkAboutThisTask = "有关本维保任务的备注信息..."
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            postButton.enabled = newValue
            
            if !newValue && isNeverInputMessage && !messageTextView.isFirstResponder() {
                messageTextView.text = remarkAboutThisTask
            }
            
            messageTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(RemarkViewController.post(_:)))
        button.enabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = NSLocalizedString("Remark", comment: "")
        view.backgroundColor = UIColor.wisBackgroundColor()
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
        // 任务描述字段的长度控制
        let messageLength = (messageTextView.text as NSString).length
        
        guard messageLength <= WISConfig.maxTaskTextLength else {
            let message = String(format: NSLocalizedString("Task info is too long!\nUp to %d letters.", comment: ""), WISConfig.maxTaskTextLength)
            WISAlert.alertSorry(message: message, inViewController: self)
            return
        }
        
        SVProgressHUD.showWithStatus("正在提交")
        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask!.taskID, remark: messageTextView.text, operationType: MaintenanceTaskOperationType.Remark, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: nil, andCompletionHandler: { (completedWithNoError, error) in
            if completedWithNoError {
                SVProgressHUD.showSuccessWithStatus("备注成功")
                self.navigationController?.popViewControllerAnimated(true)
                
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
            messageTextView.text = remarkAboutThisTask
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

//extension UIScrollView {
//    
//    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        nextResponder()?.touchesBegan(touches, withEvent: event)
//        super.touchesBegan(touches, withEvent: event)
//
//    }
//}
