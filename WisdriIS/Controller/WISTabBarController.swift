//
//  WISTabBarController.swift
//  WisdriIS
//
//  Created by Allen on 2/22/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit
import PagingMenuController

class WISTabBarController: UITabBarController {

    private enum Tab: Int {

        case Tasks
        case Inspection
        case Shift
        case Profile

        var title: String {

            switch self {
            case .Tasks:
                return NSLocalizedString("Tasks", comment: "")
            case .Shift:
                return NSLocalizedString("Shift", comment: "")
            case .Inspection:
                return NSLocalizedString("Inspection", comment: "")
            case .Profile:
                return NSLocalizedString("Profile", comment: "")
            }
        }
    }

    private var previousTab = Tab.Tasks
//    private var previousTab = tabBar.items[0]
    private var previousItem: UITabBarItem?

    private var checkDoubleTapOnTasksTimer: NSTimer?
    private var hasFirstTapOnTasksWhenItIsAtTop = false {
        willSet {
            if newValue {
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(WISTabBarController.checkDoubleTapOnTasks(_:)), userInfo: nil, repeats: false)
                checkDoubleTapOnTasksTimer = timer

            } else {
                checkDoubleTapOnTasksTimer?.invalidate()
            }
        }
    }

    @objc private func checkDoubleTapOnTasks(timer: NSTimer) {

        hasFirstTapOnTasksWhenItIsAtTop = false
    }

    deinit {

        print("deinit WISTabBar")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        view.backgroundColor = UIColor.whiteColor()

        // 将 UITabBarItem 的 image 下移一些，也不显示 title 了
        /*
        if let items = tabBar.items as? [UITabBarItem] {
            for item in items {
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                item.title = nil
            }
        }
        */

        // Set Titles
        
        if let items = tabBar.items {
            
            previousItem = items[0]
            
            if items.count == 2 {
                items[0].title = Tab.Tasks.title
                items[1].title = Tab.Profile.title
            }
            
            if items.count == 3 {
                items[0].title = Tab.Tasks.title
                items[1].title = Tab.Inspection.title
                items[2].title = Tab.Profile.title
            }

            if items.count == 4 {
                for i in 0 ..< items.count {
                    let item = items[i]
                    item.title = Tab(rawValue: i)?.title
                }
            }
        }
        
    }
}

// MARK: - UITabBarControllerDelegate

extension WISTabBarController: UITabBarControllerDelegate {

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        guard let tab = Tab(rawValue: selectedIndex),
              let _ = viewController as? UINavigationController else {
            return false
        }

        guard tab == previousTab else {
            return true
        }

        // 待完善，增加双击下拉刷新
        if case .Tasks = tab {
//            if let vc = nvc.topViewController as? TaskHomeViewController {
//                guard let taskTableView = (vc.viewControllers.first! as TaskListViewController).taskTableView else {
//                    return true
//                }
//                if taskTableView.wis_isAtTop {
//                    if !hasFirstTapOnTasksWhenItIsAtTop {
//                        hasFirstTapOnTasksWhenItIsAtTop = true
//                        return false
//                    }
//                }
//            }
        }

        return true
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
//        guard let tab = Tab(rawValue: selectedIndex),
        guard let items = tabBar.items,
              let nvc = viewController as? UINavigationController else {
            return
        }
        
        let item = items[selectedIndex]

        // 相等才继续，确保第一次 tap 不做事
        if item != previousItem {
            previousItem = item
            return
        }

        // One tap on tab scroll the tableView to the top
        switch item.title! {
            
        case NSLocalizedString("Tasks"):
            if let vc = nvc.topViewController as? TaskHomeViewController {
                guard let pageViewController = vc.childViewControllers.first as? PagingMenuController,
                      let taskTableView = (pageViewController.currentViewController as! TaskListViewController).taskTableView else {
                    return
                }
                if !taskTableView.wis_isAtTop {
                    taskTableView.wis_scrollsToTop()
                }
            }
            
        case NSLocalizedString("Inspection"):
            if let vc = nvc.topViewController as? InspectionHomeViewController {
                guard let pageViewController = vc.childViewControllers.first as? PagingMenuController,
                      let inspectionTableView = (pageViewController.currentViewController as! InspectionListViewController).inspectionTableView else {
                    return
                }
                if !inspectionTableView.wis_isAtTop {
                    inspectionTableView.wis_scrollsToTop()
                }
            }
            
        case NSLocalizedString("Shift"):
            break

        case NSLocalizedString("Profile"):
            if let vc = nvc.topViewController as? ProfileViewController {
                guard let editProfileTable = vc.editProfileTableView else {
                    return
                }
                if !editProfileTable.wis_isAtTop {
                    editProfileTable.wis_scrollsToTop()
                }
            }
            
        default:
            return
        }
        
    }
}

