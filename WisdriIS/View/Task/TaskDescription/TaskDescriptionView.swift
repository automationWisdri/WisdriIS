//
//  TaskDescriptionView.swift
//  WisdriIS
//
//  Created by Allen on 3/7/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import RealmSwift
import MapKit

class TaskDescriptionView: UIView {

//    var feed: ConversationFeed? {
//        willSet {
//            if let feed = newValue {
//                configureWithFeed(feed)
//            }
//        }
//    }

    var tapMediaAction: ((transitionView: UIView, image: UIImage?, attachments: [DiscoveredAttachment], index: Int) -> Void)?

    static let foldHeight: CGFloat = 60

    weak var heightConstraint: NSLayoutConstraint?

    class func instanceFromNib() -> TaskDescriptionView {
        return UINib(nibName: "TaskDescriptionView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! TaskDescriptionView
    }

    var foldProgress: CGFloat = 0 {
        willSet {
            if newValue >= 0 && newValue <= 1 {

//                let normalHeight = self.normalHeight
                let normalHeight: CGFloat = 200.0
                let attachmentURLsIsEmpty = attachments.isEmpty

                UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(rawValue: 0), animations: { [weak self] in

                    self?.nicknameLabelCenterYConstraint.constant = -10 * newValue
                    self?.messageTextViewTopConstraint.constant = -25 * newValue + 4

                    if newValue == 1.0 {
                        self?.nicknameLabelTrailingConstraint.constant = attachmentURLsIsEmpty ? 15 : (5 + 40 + 15)
                        self?.messageTextViewTrailingConstraint.constant = attachmentURLsIsEmpty ? 15 : (5 + 40 + 15)
                        self?.messageTextViewHeightConstraint.constant = 20
                    }

                    if newValue == 0.0 {
                        self?.nicknameLabelTrailingConstraint.constant = 15
                        self?.messageTextViewTrailingConstraint.constant = 15
                        self?.calHeightOfMessageTextView()
                    }


                    self?.heightConstraint?.constant = TaskDescriptionView.foldHeight + (normalHeight - TaskDescriptionView.foldHeight) * (1 - newValue)

                    self?.layoutIfNeeded()

                    let foldingAlpha = (1 - newValue)
//                    self?.distanceLabel.alpha = foldingAlpha
                    self?.mediaCollectionView.alpha = foldingAlpha
                    self?.timeLabel.alpha = foldingAlpha
                    self?.mediaView.alpha = newValue

                    self?.messageLabel.alpha = newValue
                    self?.messageTextView.alpha = foldingAlpha

                }, completion: { _ in
                })

                if newValue == 1.0 {
                    foldAction?()
                }

                if newValue == 0.0 {
                    unfoldAction?(self)
                }
            }
        }
    }

    var tapAvatarAction: (() -> Void)?
    var foldAction: (() -> Void)?
    var unfoldAction: (TaskDescriptionView -> Void)?

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var nicknameLabelTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var mediaView: TaskDescriptionMediaView!

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageLabelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextView: FeedTextView!
    @IBOutlet weak var messageTextViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var mediaCollectionView: UICollectionView!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!

    lazy var socialWorkHalfMaskImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "social_media_image_mask"))
        return imageView
    }()

    lazy var socialWorkFullMaskImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "social_media_image_mask_full"))
        return imageView
    }()
    
    var attachments = [DiscoveredAttachment]() {
        didSet {
            mediaCollectionView.reloadData()
            mediaView.setImagesWithAttachments(attachments)
        }
    }

    static let messageTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.mainScreen().bounds.width - (15 + 40 + 10 + 15)
        return maxWidth
        }()

    let taskMediaCellID = "TaskMediaCell"

    override func layoutSubviews() {
        super.layoutSubviews()

//        if feed?.hasSocialImage ?? false {
//            socialWorkFullMaskImageView.frame = socialWorkImageView.bounds
//        }
//
//        if feed?.hasMapImage ?? false {
//            socialWorkHalfMaskImageView.frame = locationContainerView.bounds
//        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true

        nicknameLabel.textColor = UIColor.yepTintColor()
        messageLabel.textColor = UIColor.darkGrayColor()
        messageTextView.textColor = UIColor.darkGrayColor()
        timeLabel.textColor = UIColor.grayColor()
        
        messageLabel.font = UIFont.feedMessageFont()
        messageLabel.alpha = 0

        messageTextView.scrollsToTop = false
        messageTextView.font = UIFont.feedMessageFont()
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        mediaView.alpha = 0

        mediaCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15 + 40 + 10, bottom: 0, right: 15)
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        mediaCollectionView.registerNib(UINib(nibName: taskMediaCellID, bundle: nil), forCellWithReuseIdentifier: taskMediaCellID)
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self

        let tapSwitchFold = UITapGestureRecognizer(target: self, action: "switchFold:")
        addGestureRecognizer(tapSwitchFold)
        tapSwitchFold.delegate = self

//        let tapAvatar = UITapGestureRecognizer(target: self, action: "tapAvatar:")
//        avatarImageView.userInteractionEnabled = true
//        avatarImageView.addGestureRecognizer(tapAvatar)

//        let tapSocialWork = UITapGestureRecognizer(target: self, action: "tapSocialWork:")
//        socialWorkContainerView.addGestureRecognizer(tapSocialWork)
//
//        let tapLocation = UITapGestureRecognizer(target: self, action: "tapLocation:")
//        locationContainerView.addGestureRecognizer(tapLocation)
//
//        let tapURLInfo = UITapGestureRecognizer(target: self, action: "tapURLInfo:")
//        feedURLContainerView.addGestureRecognizer(tapURLInfo)
    }

    func switchFold(sender: UITapGestureRecognizer) {

        if foldProgress == 1 {
            foldProgress = 0
        } else if foldProgress == 0 {
            foldProgress = 1
        }
    }

    func tapAvatar(sender: UITapGestureRecognizer) {

        tapAvatarAction?()
    }
    
//    var normalHeight: CGFloat {

//        guard let feed = feed else {
//            return TaskDescriptionView.foldHeight
//        }

//        let rect = feed.body.boundingRectWithSize(CGSize(width: FeedView.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.FeedView.textAttributes, context: nil)
//
//        var height: CGFloat = ceil(rect.height) + 10 + 40 + 4 + 15 + 17 + 15
//        
//        if feed.hasAttachment {
//            if feed.kind == .Audio {
//                height += 44 + 15
//            } else {
//                height += 80 + 15
//            }
//        }
//
//        return ceil(height)
//    }

    var height: CGFloat {
        return bounds.height
    }

    private func calHeightOfMessageTextView() {

        let rect = messageTextView.text.boundingRectWithSize(CGSize(width: TaskDescriptionView.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: YepConfig.FeedView.textAttributes, context: nil)
        messageTextViewHeightConstraint.constant = ceil(rect.height)
    }
/*
    private func configureWithFeed(feed: ConversationFeed) {

        let message = feed.body
        messageLabel.text = message
        messageTextView.text = message

        calHeightOfMessageTextView()

        let hasAttachment = feed.hasAttachment
        timeLabelTopConstraint.constant = hasAttachment ? (15 + (feed.kind == .Audio ? 44 : 80) + 15) : 15

        attachments = feed.attachments.map({
            //DiscoveredAttachment(kind: AttachmentKind(rawValue: $0.kind)!, metadata: $0.metadata, URLString: $0.URLString)
            DiscoveredAttachment(metadata: $0.metadata, URLString: $0.URLString, image: nil)
        })

        messageLabelTrailingConstraint.constant = attachments.isEmpty ? 15 : 60

        if let creator = feed.creator {
            let userAvatar = UserAvatar(userID: creator.userID, avatarStyle: nanoAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)

            nicknameLabel.text = creator.nickname
        }
        
        if let distance = feed.distance {
            if distance < 1 {
                distanceLabel.text = NSLocalizedString("Nearby", comment: "")
            } else {
                distanceLabel.text = "\(distance.format(".1")) km"
            }
        }

        timeLabel.text = "\(NSDate(timeIntervalSince1970: feed.createdUnixTime).timeAgo)"


        // social works

//        guard let kind = feed.kind else {
//            return
//        }
//
//        var socialWorkImageURL: NSURL?
//
//        switch kind {
//
//        case .Text:
//
//            mediaCollectionView.hidden = true
//            socialWorkContainerView.hidden = true
//            voiceContainerView.hidden = true
//            feedURLContainerView.hidden = true
//
//        case .Image:
//
//            mediaCollectionView.hidden = false
//            socialWorkContainerView.hidden = true
//
//            socialWorkBorderImageView.hidden = false
//
//            socialWorkContainerViewHeightConstraint.constant = 80
//
//        default:
//            break
//        }
//        
//        if let URL = socialWorkImageURL {
//            socialWorkImageView.kf_setImageWithURL(URL, placeholderImage: nil)
//        }
    }
*/
}

// MARK: - UIGestureRecognizerDelegate

extension TaskDescriptionView: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {

        let location = touch.locationInView(mediaCollectionView)

        if CGRectContainsPoint(mediaCollectionView.bounds, location) {
            return false
        }

        return true
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension TaskDescriptionView: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(taskMediaCellID, forIndexPath: indexPath) as! TaskMediaCell

        let attachment = attachments[indexPath.item]

        //println("attachment imageURL: \(imageURL)")
        
        cell.configureWithAttachment(attachment, bigger: (attachments.count == 1))

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
        tapMediaAction?(transitionView: transitionView, image: cell.imageView.image, attachments: attachments, index: indexPath.item)
    }
}
