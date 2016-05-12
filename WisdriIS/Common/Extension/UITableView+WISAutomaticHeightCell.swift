//
//  UITableView+WISAutomaticHeightCell.swift
//  WisdriIS
//
//  Created by Allen on 2/26/16.
//  Copyright © 2016 Wisddri. All rights reserved.
//

import UIKit
extension UITableView {

    public func wis_heightForCellWithIdentifier<T: UITableViewCell>(identifier: String, configuration: ((cell: T) -> Void)?) -> CGFloat {
        if identifier.characters.count <= 0 {
            return 0
        }
        
        let cell = self.wis_templateCellForReuseIdentifier(identifier)
        cell.prepareForReuse()
        
        if configuration != nil {
            configuration!(cell: cell as! T)
        }
        
//        cell.setNeedsUpdateConstraints();
//        cell.updateConstraintsIfNeeded();
//        self.setNeedsLayout();
//        self.layoutIfNeeded();
        
        var fittingSize = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        if self.separatorStyle != .None {
            fittingSize.height += 1.0 / UIScreen.mainScreen().scale
        }
        return fittingSize.height
    }
    
    
    private func wis_templateCellForReuseIdentifier(identifier: String) -> UITableViewCell {
        assert(identifier.characters.count > 0, "Expect a valid identifier - \(identifier)")
        if self.wis_templateCellsByIdentifiers == nil {
            self.wis_templateCellsByIdentifiers = [:]
        }
        var templateCell = self.wis_templateCellsByIdentifiers?[identifier] as? UITableViewCell
        if templateCell == nil {
            templateCell = self.dequeueReusableCellWithIdentifier(identifier)
            assert(templateCell != nil, "Cell must be registered to table view for identifier - \(identifier)")
            templateCell?.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.wis_templateCellsByIdentifiers?[identifier] = templateCell
        }
        
        return templateCell!
    }
    
    public func wis_heightForCellWithIdentifier<T: UITableViewCell>(identifier: T.Type, indexPath: NSIndexPath, configuration: ((cell: T) -> Void)?) -> CGFloat {
        let identifierStr = "\(identifier)";
        if identifierStr.characters.count == 0 {
            return 0
        }
        
//         Hit cache
        if self.wis_hasCachedHeightAtIndexPath(indexPath) {
            let height: CGFloat = self.wis_indexPathHeightCache![indexPath.section][indexPath.row]
//            NSLog("hit cache by indexPath:[\(indexPath.section),\(indexPath.row)] -> \(height)");
            return height
        }
        
        let height = self.wis_heightForCellWithIdentifier(identifierStr, configuration: configuration)
        self.wis_indexPathHeightCache![indexPath.section][indexPath.row] = height
//        NSLog("cached by indexPath:[\(indexPath.section),\(indexPath.row)] --> \(height)")
        
        return height
    }
    
    private struct AssociatedKey {
        static var CellsIdentifier = "me.wis.cellsIdentifier"
        static var HeightsCacheIdentifier = "me.wis.heightsCacheIdentifier"
        static var wisHeightCacheAbsendValue = CGFloat(-1);
    }

    private func wis_hasCachedHeightAtIndexPath(indexPath:NSIndexPath) -> Bool {
        self.wis_buildHeightCachesAtIndexPathsIfNeeded([indexPath]);
        let height = self.wis_indexPathHeightCache![indexPath.section][indexPath.row];
        return height >= 0;
    }
    
    private func wis_buildHeightCachesAtIndexPathsIfNeeded(indexPaths:Array<NSIndexPath>) -> Void {
        if indexPaths.count <= 0 {
            return ;
        }
        
        if self.wis_indexPathHeightCache == nil {
            self.wis_indexPathHeightCache = [];
        }
        
        for indexPath in indexPaths {
            let cacheSectionCount = self.wis_indexPathHeightCache!.count;
            if  indexPath.section >= cacheSectionCount {
                for i in cacheSectionCount...indexPath.section {
                    if i >= self.wis_indexPathHeightCache?.count {
                        self.wis_indexPathHeightCache!.append([])
                    }
                }
            }
            
            let cacheCount = self.wis_indexPathHeightCache![indexPath.section].count;
            if indexPath.row >= cacheCount {
                for i in cacheCount...indexPath.row {
                    if i >= self.wis_indexPathHeightCache![indexPath.section].count {
                        self.wis_indexPathHeightCache![indexPath.section].append(AssociatedKey.wisHeightCacheAbsendValue);
                    }
                }
            }
        }
        
    }
    
    private var wis_templateCellsByIdentifiers: [String : AnyObject]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.CellsIdentifier) as? [String : AnyObject]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.CellsIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var wis_indexPathHeightCache: [ [CGFloat] ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.HeightsCacheIdentifier) as? [[CGFloat]]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.HeightsCacheIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func wis_reloadData(){
        self.wis_indexPathHeightCache = [[]];
        self.reloadData();
    }

}
