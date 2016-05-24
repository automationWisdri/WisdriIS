//
//  WISTabBarController.swift
//  WisdriIS
//
//  Created by Allen on 2/22/16.
//  Copyright © 2016 Wisdri. All rights reserved.
//

import UIKit

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
            for i in 0 ..< items.count {
                let item = items[i]
                item.title = Tab(rawValue: i)?.title
            }
        }

    }
}

// MARK: - UITabBarControllerDelegate

extension WISTabBarController: UITabBarControllerDelegate {

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {

        guard
            let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController else {
                return false
        }

        if tab != previousTab {
            return true
        }

        // 待完善，增加双击下拉刷新
        if case .Tasks = tab {
            if let vc = nvc.topViewController as? TaskHomeViewController {
                guard let taskTableView = (vc.viewControllers.first! as TaskListViewController).taskTableView else {
                    return true
                }
                if taskTableView.wis_isAtTop {
                    if !hasFirstTapOnTasksWhenItIsAtTop {
                        hasFirstTapOnTasksWhenItIsAtTop = true
                        return false
                    }
                }
            }
        }

        return true
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        guard
            let tab = Tab(rawValue: selectedIndex),
            let nvc = viewController as? UINavigationController else {
                return
        }

        // 不相等才继续，确保第一次 tap 不做事

        if tab != previousTab {
            previousTab = tab
            return
        }

        switch tab {

        case .Tasks:
            if let vc = nvc.topViewController as? TaskHomeViewController {
                guard let taskTableView = (vc.viewControllers.first! as TaskListViewController).taskTableView else {
                    return
                }
                if !taskTableView.wis_isAtTop {
                    taskTableView.wis_scrollsToTop()
                }
            }

        case .Profile:
            if let vc = nvc.topViewController as? ProfileViewController {
                if !vc.editProfileTableView.wis_isAtTop {
                    vc.editProfileTableView.wis_scrollsToTop()
                }
            }
            
        default:
            return
        }
    }
}

