//
//  TaskSectionPickerItemView.swift
//  WisdriIS
//
//  Created by Allen on 3/2/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskSectionPickerItemView: UIView {

//    lazy var bubbleImageView: UIImageView = {
//        let view = UIImageView(image: UIImage(named: "skill_bubble")!)
//        return view
//    }()

    lazy var sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor.whiteColor()
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        makeUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeUI()
    }

    private func makeUI() {

//        addSubview(bubbleImageView)
//        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(sectionLabel)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        let skillLabelCenterY = NSLayoutConstraint(item: sectionLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)

        let skillLabelTrailing = NSLayoutConstraint(item: sectionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -50)

        NSLayoutConstraint.activateConstraints([skillLabelCenterY, skillLabelTrailing])

//        let bubbleImageViewCenterY = NSLayoutConstraint(item: bubbleImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
//
//        let bubbleImageViewLeading = NSLayoutConstraint(item: bubbleImageView, attribute: .Leading, relatedBy: .Equal, toItem: skillLabel, attribute: .Leading, multiplier: 1, constant: -10)
//
//        let bubbleImageViewTrailing = NSLayoutConstraint(item: bubbleImageView, attribute: .Trailing, relatedBy: .Equal, toItem: skillLabel, attribute: .Trailing, multiplier: 1, constant: 10)
//
//        NSLayoutConstraint.activateConstraints([bubbleImageViewCenterY, bubbleImageViewLeading, bubbleImageViewTrailing])
    }

    func configureWithString(sectionName: String) {
        sectionLabel.text = sectionName
        if sectionName == NSLocalizedString("Choose...", comment: "") {
            sectionLabel.textColor = UIColor.lightGrayColor()
//            bubbleImageView.image = nil
        } else {
            sectionLabel.textColor = UIColor.blackColor()
//            bubbleImageView.image = UIImage(named: "skill_bubble")
        }
    }
}

