//
//  InspectionResultSelectionCell.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 4/14/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class InspectionResultSelectionCell: InspectionDetailViewBaseCell {
    static let cellHeight: CGFloat = 140.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inspectionResultTableView: UITableView!
    
    private let inspectionSelectionCellID = "InspectionSelectionCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.text = NSLocalizedString("Inspection Result", comment: "")
        
        inspectionResultTableView.dataSource = self
        inspectionResultTableView.delegate = self
        
        inspectionResultTableView.setEditing(true, animated: true)
        inspectionResultTableView.allowsMultipleSelectionDuringEditing = true
        inspectionResultTableView.scrollsToTop = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindData(model: WISInspectionTask) {
        if model.inspectionResult != .NotSelected {
            inspectionResultTableView.selectRowAtIndexPath(NSIndexPath.init(forRow: model.inspectionResult.rawValue - 1, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
        
    }
    
    override func bringBackData(inout model: WISInspectionTask) {
        let index = (inspectionResultTableView.indexPathForSelectedRow?.row)! + 1
        model.inspectionResult = InspectionResult(rawValue: index)!
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension InspectionResultSelectionCell: UITableViewDataSource, UITableViewDelegate {
    /// Number of sections in TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// Number of Rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        switch indexPath.row {
        // Normal
        case 0:
            // let cell = tableView.dequeueReusableCellWithIdentifier(self.inspectionSelectionCellID) as UITableViewCell!
            let cell = UITableViewCell(style: .Default, reuseIdentifier: self.inspectionSelectionCellID)
            cell.accessoryType = .None
            cell.selectionStyle = .Blue
            cell.textLabel!.text = NSLocalizedString("Normal")
            // cell.setSelected(true, animated: true)
            return cell
        // Fault to Handle
        case 1:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: self.inspectionSelectionCellID)
            cell.accessoryType = .None
            cell.selectionStyle = .Gray
            cell.textLabel!.text = NSLocalizedString("Fault for Handle")
            // cell.setSelected(false, animated: true)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        // Normal
        case 0:
            if tableView.indexPathsForSelectedRows?.count > 1 {
                tableView.deselectRowAtIndexPath(NSIndexPath.init(forRow: 1, inSection: 0), animated: false)
                tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: 1, inSection: 0))?.textLabel?.textColor = UIColor.blackColor()
            }
            break
            
        case 1:
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.textColor = UIColor.redColor()
            if tableView.indexPathsForSelectedRows?.count > 1 {
                tableView.deselectRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), animated: false)
            }
            break
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        // Normal
        case 0:
            tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
            break
            
        case 1:
            tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: 1, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
            break
            
        default:
            break
        }
    }
    
    

    
    

}
