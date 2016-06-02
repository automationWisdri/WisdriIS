//
//  TaskListFilterGroupContentView.swift
//  WisdriIS
//
//  Created by Jingwei Wu on 6/1/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

class TaskListFilterGroupContentView: UIView {
    private let groupSelectionCellID = "groupSelectionCell"
    
    private let cellHeight: CGFloat = 50
    private let headerHeight: CGFloat = 35
    private let viewHeightOffset: CGFloat = 0
    
    var viewHeight: CGFloat {
        return CGFloat(TaskListGroupType.count) * cellHeight + viewHeightOffset + headerHeight
    }

    @IBOutlet weak var groupSelectionTableView: UITableView!
    
    var currentSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        groupSelectionTableView.dataSource = self
        groupSelectionTableView.delegate = self
        
        groupSelectionTableView.setEditing(false, animated: true)
        // groupSelectionTableView.allowsSelection = true
        // groupSelectionTableView.allowsMultipleSelection = false
        // groupSelectionTableView.allowsMultipleSelectionDuringEditing = false
        groupSelectionTableView.scrollsToTop = false
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension TaskListFilterGroupContentView: UITableViewDataSource, UITableViewDelegate {
    /// Number of sections in TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// Number of Rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskListGroupType.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Group Type", comment: "")
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.font = UIFont.systemFontOfSize(17)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let groupType = TaskListGroupType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch groupType {
        // None
        case .None:
            // let cell = tableView.dequeueReusableCellWithIdentifier(self.inspectionSelectionCellID) as UITableViewCell!
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: self.groupSelectionCellID)
            cell.accessoryType = .Checkmark
            cell.selectionStyle = .None
            cell.textLabel!.text = groupType.stringOfType
            cell.selected = true
            self.currentSelectedIndexPath = indexPath
            return cell
            
        // By person in charge
        case .ByPersonInCharge:
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: self.groupSelectionCellID)
            cell.accessoryType = .None
            cell.selectionStyle = .None
            cell.textLabel!.text = groupType.stringOfType
            cell.selected = false
            return cell
          
        // By task state
        case .ByTaskState:
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: self.groupSelectionCellID)
            cell.accessoryType = .None
            cell.selectionStyle = .None
            cell.textLabel!.text = groupType.stringOfType
            cell.selected = false
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row != currentSelectedIndexPath.row else {
            return
        }
        
        let newSelectedCell = tableView.cellForRowAtIndexPath(indexPath)
        let oldSelectedCell = tableView.cellForRowAtIndexPath(currentSelectedIndexPath)
        
        newSelectedCell?.accessoryType = .Checkmark
        newSelectedCell?.selected = true
        
        oldSelectedCell?.accessoryType = .None
        oldSelectedCell?.selected = false
        
        currentSelectedIndexPath = indexPath
    }
}
