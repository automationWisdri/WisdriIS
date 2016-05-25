//
//  RatingViewController.swift
//  WisdriIS
//
//  Created by Allen on 4/1/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import SVProgressHUD
import Cosmos

class RatingViewController: BaseViewController {

    @IBOutlet weak var ratingSummaryLabel: UILabel!
    @IBOutlet weak var ratingCommentLabel: UILabel!
    @IBOutlet weak var ratingDetailOneLabel: UILabel!
    @IBOutlet weak var ratingDetailTwoLabel: UILabel!
    @IBOutlet weak var ratingDetailThreeLabel: UILabel!
    
    @IBOutlet weak var ratingSummaryCosmos: CosmosView!
    @IBOutlet weak var ratingCommentTextView: UITextView!
    @IBOutlet weak var ratingDetailOneCosmos: CosmosView!
    @IBOutlet weak var ratingDetailTwoCosmos: CosmosView!
    @IBOutlet weak var ratingDetailThreeCosmos: CosmosView!
    
    @IBOutlet weak var ratingTopDivisionLine: HorizontalLineView!
    @IBOutlet weak var ratingBottomDivisionLine: HorizontalLineView!
    
    @IBOutlet weak var ratingScrollView: UIScrollView!
    
    private lazy var postButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""), style: .Plain, target: self, action: #selector(RatingViewController.post(_:)))
        button.enabled = false
        return button
    }()
    
    // TextView related
    private let infoAboutThisRating = NSLocalizedString("Comment about this Task...", comment: "")
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            postButton.enabled = newValue
            
            if !newValue && isNeverInputMessage && !ratingCommentTextView.isFirstResponder() {
                ratingCommentTextView.text = infoAboutThisRating
            }
            
            ratingCommentTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
//    private var wisTaskRating =  WISMaintenanceTaskRating()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.userInteractionEnabled = true
        self.ratingScrollView.delegate = self
        
        self.ratingCommentTextView.scrollsToTop = false
        
//        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(RatingViewController.singleTapped(_:)))
//        self.view.addGestureRecognizer(singleTap)
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
        title = NSLocalizedString("Task Rating")
        
        view.backgroundColor = UIColor.wisBackgroundColor()
        navigationItem.rightBarButtonItem = postButton
        
        isDirty = false
        
        ratingSummaryLabel.text = "总体评价"
        ratingCommentLabel.text = "意见与建议"
//        ratingCommentTextView
        ratingDetailOneLabel.text = "维保技术水平"
        ratingDetailTwoLabel.text = "维保响应速度"
        ratingDetailThreeLabel.text = "维保服务态度"
        
        let touchCosmos: ( (Double) -> Void ) = { _ in
            self.ratingCommentTextView.resignFirstResponder()
        }
        
        ratingSummaryCosmos.didTouchCosmos = touchCosmos
        ratingDetailOneCosmos.didTouchCosmos = touchCosmos
        ratingDetailTwoCosmos.didTouchCosmos = touchCosmos
        ratingDetailThreeCosmos.didTouchCosmos = touchCosmos
        
        //        ratingSummaryCosmos.didFinishTouchingCosmos = didFinishTouchingCosmosTotal
        
        ratingCommentTextView.textContainer.lineFragmentPadding = 0
        ratingCommentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        ratingCommentTextView.backgroundColor = UIColor.wisBackgroundColor()
        ratingCommentTextView.delegate = self
        
    }
    
    func singleTapped(gesture: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//        self.ratingCommentTextView.resignFirstResponder()
    }
    
    @objc private func cancel(sender: UIBarButtonItem) {
        
        ratingCommentTextView.resignFirstResponder()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func post(sender: UIBarButtonItem) {
        
        SVProgressHUD.showWithStatus("正在提交")
        let wisTaskRating = WISMaintenanceTaskRating(totalScore: Int(ratingSummaryCosmos.rating), attitudeScore: Int(ratingDetailThreeCosmos.rating), responseScore: Int(ratingDetailTwoCosmos.rating), qualityScore: Int(ratingDetailOneCosmos.rating), andAdditionalRemark: ratingCommentTextView.text)
//        wisTaskRating.totalScore = Int(ratingSummaryCosmos.rating)
//        wisTaskRating.additionalRemark = ratingCommentTextView.text
//        wisTaskRating.attitudeScore = Int(ratingDetailThreeCosmos.rating)
//        wisTaskRating.qualityScore = Int(ratingDetailOneCosmos.rating)
//        wisTaskRating.responseScore = Int(ratingDetailTwoCosmos.rating)
        
        WISDataManager.sharedInstance().maintenanceTaskOperationWithTaskID(currentTask?.taskID, remark: "评价", operationType: MaintenanceTaskOperationType.Confirm, taskReceiverName: nil, maintenancePlanEstimatedEndingTime: nil, maintenancePlanDescription: nil, maintenancePlanParticipants: nil, taskImageInfo: nil, taskRating: wisTaskRating) { (completedWithNoError, error) in
            if completedWithNoError {
                SVProgressHUD.setDefaultMaskType(.None)
                SVProgressHUD.showSuccessWithStatus("评价成功")
                
//                let destinationVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! TaskHomeViewController
//                self.navigationController?.popToViewController(destinationVC, animated: true)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                
                WISConfig.errorCode(error)
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        restoreTextViewPlaceHolder()
    }

    private func restoreTextViewPlaceHolder() {
        ratingCommentTextView.resignFirstResponder()
        
        if !isDirty && isNeverInputMessage {
            ratingCommentTextView.text = infoAboutThisRating
            ratingCommentTextView.textColor = UIColor.lightGrayColor()
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
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }

}

// MARK: - UITextViewDelegate

extension RatingViewController: UITextViewDelegate {
    
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

extension RatingViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
//        ratingCommentTextView.resignFirstResponder()
        restoreTextViewPlaceHolder()
    }
}