//
//  InspectionResultCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionResultDescriptionCell: InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 120.0
    
    @IBOutlet weak var inspectionResultDescriptionTitleLabel: UILabel!
    @IBOutlet weak var inspectionResultDescriptionTextView: UITextView!
    
    private let infoAboutThisFeed = NSLocalizedString("Add more on this inspection task...", comment: "")
    
    private var isNeverInputMessage = true
    private var textViewIsDirty = false {
        willSet {
            // postButton.enabled = newValue
            
            if !newValue && isNeverInputMessage && inspectionResultDescriptionTextView.editable {
                inspectionResultDescriptionTextView.text = infoAboutThisFeed
            }
            inspectionResultDescriptionTextView.textColor = newValue ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textViewIsDirty = false
        isNeverInputMessage = true
        inspectionResultDescriptionTitleLabel.text = NSLocalizedString("Inspection Result Description", comment: "")
        inspectionResultDescriptionTextView.delegate = self
        inspectionResultDescriptionTextView.returnKeyType = .Default
        inspectionResultDescriptionTextView.editable = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask, editable: Bool) {
        inspectionResultDescriptionTextView.editable = editable
        if inspectionResultDescriptionTextView.editable {
            // inspectionResultDescriptionTextView.text = ""
        } else {
            inspectionResultDescriptionTextView.text = model.inspectionResultDescription
        }
    }
    
    override func bringBackData(inout model: WISInspectionTask) {
        super.bringBackData(&model)
        if inspectionResultDescriptionTextView.text == infoAboutThisFeed {
            model.inspectionResultDescription = ""
        } else {
            model.inspectionResultDescription = inspectionResultDescriptionTextView.text
        }
    }
}

// MARK: - UITextViewDelegate

extension InspectionResultDescriptionCell: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if !textViewIsDirty {
            textView.text = ""
        }
        isNeverInputMessage = false
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView.text == "" {
            isNeverInputMessage = true
            textViewIsDirty = false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        textViewIsDirty = NSString(string: textView.text).length > 0
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}