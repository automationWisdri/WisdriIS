//
//  TaskSectionPickerItemView.swift
//  WisdriIS
//
//  Created by Allen on 3/2/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskSectionPickerItemView: UIView {

    lazy var sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(17)
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

        addSubview(sectionLabel)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        let sectionLabelCenterY = NSLayoutConstraint(item: sectionLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)

        let sectionLabelTrailing = NSLayoutConstraint(item: sectionLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -50)

        NSLayoutConstraint.activateConstraints([sectionLabelCenterY, sectionLabelTrailing])

    }

    func configureWithString(sectionName: String) {
        sectionLabel.text = sectionName
        if sectionName == NSLocalizedString("Choose...", comment: "") {
            sectionLabel.textColor = UIColor.lightGrayColor()
        } else {
            sectionLabel.textColor = UIColor.blackColor()
        }
    }
}

