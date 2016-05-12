//
//  TaskDetailLargeInfoCell.swift
//  WisdriIS
//
//  Created by Allen on 3/7/2016.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskDetailLargeInfoCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!

    @IBOutlet weak var infoTextView: UITextView!

    var infoTextViewIsDirtyAction: (Bool -> Void)?
    var infoTextViewDidEndEditingAction: (String -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .None

        infoTextView.font = YepConfig.EditProfile.introFont
        infoTextView.textContainer.lineFragmentPadding = 0
        infoTextView.textContainerInset = UIEdgeInsetsZero
        infoTextView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TaskDetailLargeInfoCell: UITextViewDelegate {

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {

        // 初次设置前，清空 placeholder
        if YepUserDefaults.introduction.value == nil {
            textView.text = ""
        }

        return true
    }

    func textViewDidChange(textView: UITextView) {

        let isDirty = NSString(string: textView.text).length > 0
        infoTextViewIsDirtyAction?(isDirty)
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView == infoTextView {
            let text = textView.text.trimming(.WhitespaceAndNewline)
            textView.text = text
            infoTextViewDidEndEditingAction?(text)
        }
    }
}