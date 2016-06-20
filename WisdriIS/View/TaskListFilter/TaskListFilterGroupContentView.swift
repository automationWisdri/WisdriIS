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
    
    var currentSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0) {
        didSet {
            if currentSelectedIndexPath.row != oldValue.row {
                let newSelectedCell = self.groupSelectionTableView.cellForRowAtIndexPath(currentSelectedIndexPath)
                let oldSelectedCell = self.groupSelectionTableView.cellForRowAtIndexPath(oldValue)
                
                newSelectedCell?.accessoryType = .Checkmark
                newSelectedCell?.selected = true
                
                oldSelectedCell?.accessoryType = .None
                oldSelectedCell?.selected = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        groupSelectionTableView.dataSource = self
        groupSelectionTableView.delegate = self
        
        groupSelectionTableView.separatorColor = UIColor.wisCellSeparatorColor()
        
        groupSelectionTableView.setEditing(false, animated: true)
        // groupSelectionTableView.allowsSelection = true
        // groupSelectionTableView.allowsMultipleSelection = false
        // groupSelectionTableView.allowsMultipleSelectionDuringEditing = false
        groupSelectionTableView.scrollsToTop = false
    }
    
    func bindData(initialGroupType: TaskListGroupType) {
        self.currentSelectedIndexPath = NSIndexPath(forRow: initialGroupType.rawValue, inSection: 0)
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
        
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: self.groupSelectionCellID)
        cell.textLabel!.text = groupType.stringOfType
        cell.indentationLevel = 1
        cell.selectionStyle = .Default
        
        if indexPath.row == currentSelectedIndexPath.row {
            cell.accessoryType = .Checkmark
            cell.selected = true
        } else {
            cell.accessoryType = .None
            cell.selected = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row != currentSelectedIndexPath.row else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        let newSelectedCell = tableView.cellForRowAtIndexPath(indexPath)
        let oldSelectedCell = tableView.cellForRowAtIndexPath(currentSelectedIndexPath)
        
        newSelectedCell?.accessoryType = .Checkmark
        newSelectedCell?.selected = true
        
        oldSelectedCell?.accessoryType = .None
        oldSelectedCell?.selected = false
        
        currentSelectedIndexPath = indexPath
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
}
