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

    private var checkDoubleTapOnFeedsTimer: NSTimer?
    private var hasFirstTapOnFeedsWhenItIsAtTop = false {
        willSet {
            if newValue {
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDoubleTapOnFeeds:", userInfo: nil, repeats: false)
                checkDoubleTapOnFeedsTimer = timer

            } else {
                checkDoubleTapOnFeedsTimer?.invalidate()
            }
        }
    }

    @objc private func checkDoubleTapOnFeeds(timer: NSTimer) {

        hasFirstTapOnFeedsWhenItIsAtTop = false
    }

    private struct Listener {
        static let lauchStyle = "WISTabBarController.lauchStyle"
    }

//    deinit {
//        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
//            appDelegate.lauchStyle.removeListenerWithName(Listener.lauchStyle)
//        }
//
//        println("deinit WISTabBar")
//    }

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
            for i in 0..<items.count {
                let item = items[i]
                item.title = Tab(rawValue: i)?.title
            }
        }

        // 处理启动切换

//        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
//            appDelegate.lauchStyle.bindListener(Listener.lauchStyle) { [weak self] style in
//                if style == .Message {
//                    self?.selectedIndex = 0
//                }
//            }
//        }
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

//        if case .Feeds = tab {
//            if let vc = nvc.topViewController as? FeedsViewController {
//                guard let feedsTableView = vc.feedsTableView else {
//                    return true
//                }
//                if feedsTableView.wis_isAtTop {
//                    if !hasFirstTapOnFeedsWhenItIsAtTop {
//                        hasFirstTapOnFeedsWhenItIsAtTop = true
//                        return false
//                    }
//                }
//            }
//        }

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

//        switch tab {

//        case .Tasks:
//            if let vc = nvc.topViewController as? TasksViewController {
//                if !vc.conversationsTableView.wis_isAtTop {
//                    vc.conversationsTableView.wis_scrollsToTop()
//                }
//            }

//        case .Contacts:
//            if let vc = nvc.topViewController as? ContactsViewController {
//                if !vc.contactsTableView.wis_isAtTop {
//                    vc.contactsTableView.wis_scrollsToTop()
//                }
//            }

//        case .Feeds:
//            if let vc = nvc.topViewController as? FeedsViewController {
//                if !vc.feedsTableView.wis_isAtTop {
//                    vc.feedsTableView.wis_scrollsToTop()
//
//                } else {
//                    if !vc.feeds.isEmpty && !vc.pullToRefreshView.isRefreshing {
//                        vc.feedsTableView.setContentOffset(CGPoint(x: 0, y: -150), animated: true)
//                        hasFirstTapOnFeedsWhenItIsAtTop = false
//                    }
//                }
//            }

//        case .Schedule:
//            if let vc = nvc.topViewController as? ScheduleViewController {
//                if !vc.discoveredUsersCollectionView.wis_isAtTop {
//                    vc.discoveredUsersCollectionView.wis_scrollsToTop()
//                }
//            }

//        case .Profile:
//            if let vc = nvc.topViewController as? ProfileViewController {
//                if !vc.profileCollectionView.wis_isAtTop {
//                    vc.profileCollectionView.wis_scrollsToTop()
//                }
//            }
//        }

        /*
        if selectedIndex == 1 {
            if let nvc = viewController as? UINavigationController, vc = nvc.topViewController as? ContactsViewController {
                syncFriendshipsAndDoFurtherAction {
                    dispatch_async(dispatch_get_main_queue()) { [weak vc] in
                        vc?.updateContactsTableView()
                    }
                }
            }
        }
        */
    }
}

