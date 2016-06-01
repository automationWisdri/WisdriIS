//
//  TaskRateCell.swift
//  WisdriIS
//
//  Created by Allen on 6/1/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import Cosmos

class TaskRateCell: UITableViewCell {

    @IBOutlet weak var totalScoreCosmos: CosmosView!
    @IBOutlet weak var scoreDetailLabel: UILabel!
    @IBOutlet weak var remarkTextView: TaskTextView!
    @IBOutlet weak var remarkTextViewHeightConstraint: NSLayoutConstraint!
    
    static let remarkTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.mainScreen().bounds.width - (20 + 10)
        return maxWidth
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        remarkTextView.textContainer.lineFragmentPadding = 0
        remarkTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        remarkTextView.scrollsToTop = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func getScoreComment(score: Int) -> String {
        switch score {
            case 1: return "1(差)"
            case 2: return "2(不好)"
            case 3: return "3(一般)"
            case 4: return "4(好)"
            case 5: return "5(很好)"
            default: return EMPTY_STRING
        }
    }
    
    func bind(rating: WISMaintenanceTaskRating) {
        totalScoreCosmos.rating = Double(rating.totalScore)
        let attitude = "服务" + getScoreComment(rating.attitudeScore)
        let response = "速度" + getScoreComment(rating.responseScore)
        let quality = "质量" + getScoreComment(rating.qualityScore)
        scoreDetailLabel.text = attitude + "  " + response + "  " + quality
        remarkTextView.text = rating.additionalRemark
        
        remarkTextViewHeightConstraint.constant = calHeightOfTextView(text: remarkTextView.text)
    }
    
    func calHeightOfCell(rating: WISMaintenanceTaskRating) -> CGFloat {
        
        var heightOfCell: CGFloat
        
        let remarkTextHeight = calHeightOfTextView(text: rating.additionalRemark)
        
        heightOfCell = 68 + remarkTextHeight
        
        return heightOfCell
    }
    
    private func calHeightOfTextView(text text: String) -> CGFloat {
        
        let rect = text.boundingRectWithSize(CGSize(width: TaskRateCell.remarkTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: WISConfig.TaskDescriptionCell.textAttributes, context: nil)
        
        return ceil(rect.height)
    }
    
}
